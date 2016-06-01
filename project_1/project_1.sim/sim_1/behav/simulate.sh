#!/bin/bash -f
xv_path="/opt/Xilinx/Vivado/2015.3"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xsim tb_behav -key {Behavioral:sim_1:Functional:tb} -tclbatch tb.tcl -view /home/mistrz/Desktop/test_bench_usb/project_1/tb_behav.wcfg -view /home/mistrz/Desktop/test_bench_usb/project_1/tb_behav1.wcfg -view /home/mistrz/Desktop/test_bench_usb/project_1/tb_behav2.wcfg -view /home/mistrz/Desktop/test_bench_usb/project_1/tb_behav3.wcfg -view /home/mistrz/Desktop/test_bench_usb/project_1/tb_behav4.wcfg -view /home/mistrz/Desktop/test_bench_usb/project_1/test.wcfg -view /home/mistrz/Desktop/test_bench_usb/project_1/pl.wcfg -view /home/mistrz/Desktop/test_bench_usb/project_1/pd.wcfg -log simulate.log
