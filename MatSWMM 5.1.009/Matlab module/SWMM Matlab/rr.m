loadlibrary prueba;

str = libpointer('stringPtrPtr', {''});
calllib('prueba', 'get', str);
str.value