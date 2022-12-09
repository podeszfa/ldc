package ldc

import "testing"

func FuzzTranspile(f *testing.F) {
	tests := []string{
		"XIC(NowyA1)XIO(NowyAlarm)ONS(ONS.1)OTL(NowyAlarm)MOV(1,AlarmNr)FFL(AlarmNr,FIFO[0],ControlFIFO,?,?);",
		"XIO(input_a)[XIO(input_b),[XIO(input_c1),XIO(input_c2)]XIC(input_d)]OTE(output);",
		"XO(input_xo)XC(input_xc)XP(input_xp)XN(input_xn)XPN(input_xpn)CO(output_co)CC(output_cc)CS(output_cs)CR(output_cr)CP(output_cp)CN(output_cn)CPN(output_cpn);",
	}

	for _, tt := range tests {
		f.Add(tt)
	}

	f.Fuzz(func(t *testing.T, arg string) {
		Transpile(arg, "test", "")
	})
}
