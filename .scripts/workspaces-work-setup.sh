sleep 1

i3-msg "[workspace=$ws1] move workspace to output $MONITOR_LAPTOP"
i3-msg "[workspace=$ws2] move workspace to output $MONITOR_LAPTOP"
i3-msg "[workspace=$ws3] move workspace to output $MONITOR_LAPTOP"


i3-msg "[workspace=$ws7] move workspace to output $MONITOR_WORK_2"
i3-msg "[workspace=$ws6] move workspace to output $MONITOR_WORK_2"
i3-msg "[workspace=$ws5] move workspace to output $MONITOR_WORK_2"
i3-msg "[workspace=$ws4] move workspace to output $MONITOR_WORK_2"

i3-msg "[workspace=$ws8] move workspace to output $MONITOR_WORK_3"
i3-msg "[workspace=$ws9] move workspace to output $MONITOR_WORK_3"
i3-msg "[workspace=$ws10] move workspace to output $MONITOR_WORK_3"