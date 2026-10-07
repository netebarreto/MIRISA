"""Generate daily climatologies/anomalies; keep historical MCA inputs separate."""
import argparse
from datetime import date, timedelta, datetime
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile


def check_daily_coverage(timestamps, start, end):
    """Reject missing days, duplicates and subdaily input in each reference."""
    days = [datetime.fromisoformat(t).date() for t in timestamps]
    days = [d for d in days if start <= d <= end]
    expected = [start + timedelta(days=i) for i in range((end-start).days+1)]
    if days != expected:
        raise ValueError(f'Referência {start}/{end}: requer um registro por dia, em ordem, sem lacunas.')


def component(value):
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_.-]*', value):
        raise argparse.ArgumentTypeError('Use somente letras, números, _, . e - nos identificadores.')
    return value


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--variable', required=True, choices=['prec','uwnd','vwnd','olr'])
    parser.add_argument('--source', required=True, type=component)
    parser.add_argument('--version', type=component, help='Obrigatória para precipitação: versão e variante.')
    parser.add_argument('--level', type=int, choices=[200,850], help='Pressão em hPa; entrada CDO deve usar hPa.')
    parser.add_argument('--input', required=True, type=Path, help='NetCDF diário contínuo, uma variável.')
    parser.add_argument('--period', default=os.getenv('MIRISA_CLIM_PERIOD','all'), help='all ou ID em config/climatology_periods.json')
    parser.add_argument('--mode', choices=['climatology','standardize'], default='climatology')
    parser.add_argument('--filter-method', type=component, help='Obrigatório em standardize; a entrada deve estar previamente filtrada para a referência escolhida.')
    parser.add_argument('--dry-run', action='store_true', help='Somente mostrar comandos; não verifica os dados.')
    args = parser.parse_args()
    root = Path(os.getenv('MIRISA_ROOT') or Path(__file__).resolve().parents[2]).resolve()
    config = json.loads((root/'config/climatology_periods.json').read_text())
    periods = config['periods']
    if args.period != 'all' and args.period not in periods:
        parser.error(f'Período inválido: {args.period}; use all ou {list(periods)}')
    if args.mode == 'standardize' and (args.period == 'all' or not args.filter_method):
        parser.error('standardize requer --period único e --filter-method; cada referência precisa de suas próprias anomalias filtradas.')
    if args.variable == 'prec' and not args.version:
        parser.error('--version é obrigatória para precipitação; identifica também a variante diária.')
    if args.variable in ('uwnd','vwnd') and args.level is None:
        parser.error('--level é obrigatório para ventos; não misture níveis.')
    if args.variable not in ('uwnd','vwnd') and args.level is not None:
        parser.error('--level é reservado aos ventos.')
    source_file = args.input.resolve()
    if not args.dry_run:
        if not source_file.is_file(): parser.error(f'Entrada ausente: {source_file}')
        if not shutil.which('cdo'): parser.error('CDO não encontrado no PATH.')
        names = subprocess.check_output(['cdo','-s','showname',str(source_file)], text=True).split()
        if len(names) != 1: parser.error('Forneça exatamente uma variável NetCDF (selname antes de executar).')
        timestamps = subprocess.check_output(['cdo','-s','showtimestamp',str(source_file)], text=True).split()
        if args.level is not None:
            levels = subprocess.check_output(['cdo','-s','showlevel',str(source_file)], text=True).split()
            if args.level not in [float(v) for v in levels]:
                parser.error(f'Nível {args.level} ausente; confira se o eixo está em hPa.')
    selected = periods if args.period == 'all' else {args.period:periods[args.period]}
    # Preflight all requested references before writing any of them.
    if not args.dry_run:
        for bounds in selected.values():
            check_daily_coverage(timestamps, date.fromisoformat(bounds['start']), date.fromisoformat(bounds['end']))
    suffix = Path(args.source)
    if args.version: suffix /= args.version
    if args.level is not None: suffix /= f'{args.level}hpa'
    destinations = {}
    for period in selected:
        if args.mode == 'climatology':
            destinations[period] = (root/'data'/args.variable/'climatologia'/suffix/period/'media_diaria.nc', root/'data'/args.variable/'anomalias'/suffix/period/'anomalias.nc')
        else:
            destinations[period] = (root/'data'/args.variable/'desvio_padrao'/suffix/period/args.filter_method/'desvio.nc', root/'data'/args.variable/'padronizados'/suffix/period/args.filter_method/'padronizados.nc')
        if not args.dry_run:
            for path in destinations[period]:
                if path.exists(): parser.error(f'Saída existente: {path}. Use outra versão ou remova conscientemente o produto anterior.')
    for period, bounds in selected.items():
        mean_file, anomaly_file = destinations[period]
        level_op = [f'-sellevel,{args.level}'] if args.level is not None else []
        reference_op = '-ydaymean' if args.mode == 'climatology' else '-timstd'
        series_op = '-ydaysub' if args.mode == 'climatology' else '-div'
        mean_cmd = ['cdo','-s','-b','F32',reference_op,f"-seldate,{bounds['start']},{bounds['end']}",*level_op,str(source_file)]
        anom_cmd = ['cdo','-s','-b','F32',series_op,*level_op,str(source_file)]
        if args.dry_run:
            print(json.dumps({'period':period, 'mean_command':mean_cmd+[str(mean_file)], 'anomaly_command':anom_cmd+[str(mean_file),str(anomaly_file)]},ensure_ascii=False))
            continue
        mean_file.parent.mkdir(parents=True,exist_ok=True)
        anomaly_file.parent.mkdir(parents=True,exist_ok=True)
        with tempfile.TemporaryDirectory(dir=mean_file.parent) as staging:
            mean_tmp = Path(staging)/'media.nc'
            anomaly_tmp = Path(staging)/'anomalias.nc'
            subprocess.run(mean_cmd+[str(mean_tmp)],check=True)
            subprocess.run(anom_cmd+[str(mean_tmp),str(anomaly_tmp)],check=True)
            mean_tmp.replace(mean_file)
            anomaly_tmp.replace(anomaly_file)
        metadata = dict(variable=args.variable, source=args.source, version=args.version, level_hpa=args.level,
                        reference=period, bounds=bounds, input=str(source_file), mean_command=mean_cmd,
                        mode=args.mode, filter_method=args.filter_method,
                        calendar='Gregorian daily; complete reference dates checked',
                        leap_day='CDO ydaymean/ydaysub defaults; inspect before comparing calendars',
                        note='Missing grid values are not checked by the temporal coverage check.')
        (mean_file.parent/'manifest.json').write_text(json.dumps(metadata,indent=2,ensure_ascii=False)+'\n')
        print(f'{period}: {mean_file}\n{anomaly_file}')


if __name__ == '__main__':
    main()
