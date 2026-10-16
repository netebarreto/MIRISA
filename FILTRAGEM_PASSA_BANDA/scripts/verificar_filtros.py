#!/usr/bin/env python3
"""Verificações numéricas do laboratório; executa: python scripts/verificar_filtros.py."""
import json
import unittest
import numpy as np
from scipy import signal
from comparar_filtros import ROOT, aplicar, lanczos, projetar

class VerificarFiltros(unittest.TestCase):
    def setUp(self):
        self.c = json.loads((ROOT/'exemplos/parametros.json').read_text())

    def test_lanczos_simetria_e_ganho(self):
        h = lanczos(401,1/90,1/30,1)
        np.testing.assert_allclose(h,h[::-1],atol=1e-14)
        _, response = signal.freqz(h,worN=[np.sqrt(1/90*1/30)],fs=1)
        self.assertAlmostEqual(abs(response[0]),1,places=12)
        self.assertLess(abs(sum(h)),.02)

    def test_especificacoes_iir_e_estabilidade(self):
        for pmin,pmax,dt in [(30,90,1),(7,30,1),(10,90,.25)]:
            c = dict(self.c,periodo_min_dias=pmin,periodo_max_dias=pmax,dt_dias=dt)
            filters, fs, (low,high), ws = projetar(c)
            f = np.linspace(0,fs/2,50000)
            for name,(kind,coef) in filters.items():
                if kind != 'iir':
                    continue
                with self.subTest(banda=(pmin,pmax,dt),filtro=name):
                    _, poles, _ = signal.sos2zpk(coef)
                    self.assertTrue((abs(poles)<1).all())
                    _, h = signal.sosfreqz(coef,worN=f,fs=fs)
                    db = 40*np.log10(np.maximum(abs(h),1e-100))
                    self.assertGreaterEqual(db[(f>=low)&(f<=high)].min(),-1.001)
                    self.assertLessEqual(db[(f<=ws[0])|(f>=ws[1])].max(),-39.999)

    def test_aplicacao_recupera_ganho_teorico(self):
        filters, fs, (low,high), _ = projetar(self.c)
        f = np.sqrt(low*high)
        t = np.arange(16000)
        x = np.sin(2*np.pi*f*t)
        for name,(kind,coef) in filters.items():
            with self.subTest(filtro=name):
                y = aplicar(x,kind,coef)
                h = (signal.sosfreqz(coef,worN=[f],fs=fs)[1] if kind=='iir'
                     else signal.freqz(coef,worN=[f],fs=fs)[1])
                expected = abs(h[0])**(2 if kind=='iir' else 1)
                core = slice(4000,-4000)
                basis = np.column_stack([np.sin(2*np.pi*f*t[core]),np.cos(2*np.pi*f*t[core])])
                amplitude = np.linalg.norm(np.linalg.lstsq(basis,y[core],rcond=None)[0])
                self.assertAlmostEqual(amplitude,expected,places=4)

    def test_entrada_invalida(self):
        for changes in [dict(dt_dias=0),dict(periodo_min_dias=2),dict(numtaps=100)]:
            with self.assertRaises(ValueError):
                projetar(dict(self.c,**changes))
        with self.assertRaises(ValueError):
            aplicar([1,np.nan,2],'fir',np.ones(3))

if __name__ == '__main__':
    unittest.main(verbosity=2)
