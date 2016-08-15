float mplant_tool_smart_com(float _msg, float _f1, float _f2)
{
    return true;
}

bool mplant_tool_smart(entity this)
{
    PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = false;
    return true;
}
