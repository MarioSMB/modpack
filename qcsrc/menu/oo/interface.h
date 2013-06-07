#ifndef INTERFACE
#define INTERFACE
#endif

#ifdef IMPLEMENTATION
#undef IMPLEMENTATION
#endif

#ifdef CLASS
#undef CLASS
#undef EXTENDS
#undef METHOD
#undef ATTRIB
#undef ATTRIBARRAY
#undef ENDCLASS
#undef SUPER
#endif

#define CLASS(cname)                       entity spawn##cname(); entity cname##_vtbl;
#define EXTENDS(base)                
#define METHOD(cname,name,prototype)       prototype cname##_##name; .prototype name;
#define ATTRIB(cname,name,type,val)        .type name;
#define ATTRIBARRAY(cname,name,type,cnt)   .type name[cnt];
#define ENDCLASS(cname)                    .float instanceOf##cname;
#define SUPER(cname)
