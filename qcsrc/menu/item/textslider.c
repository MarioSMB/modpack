// Note:
//   to use this, you FIRST call configureSliderVisuals, then multiple times addValue, then configureTextSlider
#ifdef INTERFACE
CLASS(TextSlider) EXTENDS(Slider)
	METHOD(TextSlider, valueToText, string(entity, float))
	METHOD(TextSlider, valueToIdentifier, string(entity, float))
	METHOD(TextSlider, setValueFromIdentifier, void(entity, string))
	METHOD(TextSlider, getIdentifier, string(entity))
	METHOD(TextSlider, addValue, void(entity, string, string))
	METHOD(TextSlider, configureTextSliderValues, void(entity, string))
	ATTRIBARRAY(TextSlider, valueStrings, string, 256)
	ATTRIBARRAY(TextSlider, valueIdentifiers, string, 256)
	ATTRIB(TextSlider, nValues, float, 0)
ENDCLASS(TextSlider)
#endif

#ifdef IMPLEMENTATION
string TextSlider_valueToIdentifier(entity me, float val)
{
	if(val >= me.nValues)
		return "custom";
	if(val < 0)
		return "custom";
	return me.(valueIdentifiers[val]);
}
string TextSlider_valueToText(entity me, float val)
{
	if(val >= me.nValues)
		return _("custom");
	if(val < 0)
		return _("custom");
	return me.(valueStrings[val]);
}
void TextSlider_setValueFromIdentifier(entity me, string id)
{
	float i;
	for(i = 0; i < me.nValues; ++i)
		if(me.valueToIdentifier(me, i) == id)
		{
			SUPER(TextSlider).setValue( me, i );
			return;
		}
	SUPER(TextSlider).setValue( me, -1 );
}
string TextSlider_getIdentifier(entity me)
{
	return me.valueToIdentifier(me, me.value);
}
void TextSlider_addValue(entity me, string theString, string theIdentifier)
{
	me.(valueStrings[me.nValues]) = theString;
	me.(valueIdentifiers[me.nValues]) = theIdentifier;
	me.nValues += 1;
}
void TextSlider_configureTextSliderValues(entity me, string theDefault)
{
	me.configureSliderValues(me, 0, 0, me.nValues - 1, 1, 1, 1);
	me.setValueFromIdentifier(me, theDefault);
}
#endif
