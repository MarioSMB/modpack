#!/bin/sh

{
	grep -h '\<precache_model *( *"' client/* | grep -v "//NO_SV_PRECACHE"
	grep -h '\<precache_sound *( *"' client/* | grep -v "//NO_SV_PRECACHE"
} > server/precache-for-csqc.inc

