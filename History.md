# Version history for the _Autoloaded_ project

## <a name="v2.2.1"></a>v2.2.1 and <a name="v1.5.1"></a>v1.5.1, Wed 10/18/2017

* Eliminate Ruby warnings about undefined instance variables

## <a name="v2.2.0"></a>v2.2.0 and <a name="v1.5.0"></a>v1.5.0, Wed 2/22/2017

* Add support for Ruby load paths (`$:`) that contain one or more
  [_Pathname_][Ruby-Stdlib-Pathname] objects

## <a name="v2.1.1"></a>v2.1.1 and <a name="v1.4.1"></a>v1.4.1, Sat 1/24/2015

* Don’t warn about a _VERSION_ constant presumably loaded by a _.gemspec_

## <a name="v2.0.0"></a>v2.0.0, Sat 12/27/2014

* Add support for Ruby v1.9.x
* Remove deprecated API

## <a name="v1.3.0"></a>v1.3.0, Fri 12/26/2014

* Add support for relative class references with a new API

## <a name="v1.2.0"></a>v1.2.0, Fri 11/28/2014

* Add support for [JRuby][JRuby] (Ruby v2.x-compatible versions)

## <a name="v1.1.0"></a>v1.1.0, Tue 11/04/2014

* Correct/improve autoload behavior
  * Instead of returning the source **directory** path from
    [_Module#autoload?_][Ruby-Core-Module-autoload], return one or more matching
    source **file** path(s)
  * Use Ruby load path (`$:`) to handle relative source file paths
  * Explain _Module#autoload?_ and
    [_Module#constants_][Ruby-Core-Module-constants] in the [readme][readme] and
    in [inline documentation][inline-documentation]

## <a name="v1.0.0"></a>v1.0.0, Wed 10/29/2014

* Add support for Ruby v2.0

## <a name="v0.0.3"></a>v0.0.3, Fri 10/24/2014

(First release)

[JRuby]:                      http://jruby.org
[Ruby-Core-Module-autoload]:  http://ruby-doc.org/core/Module.html#method-i-autoload-3F     "‘Module#autoload’ method in the Ruby Core Library"
[Ruby-Core-Module-constants]: http://ruby-doc.org/core/Module.html#method-i-constants       "‘Module#constants’ method in the Ruby Core Library"
[Ruby-Stdlib-Pathname]:       http://ruby-doc.org/stdlib/libdoc/pathname/rdoc/Pathname.html "‘Pathname’ class in the Ruby Standard Library"
[readme]:                     http://github.com/njonsson/autoloaded/blob/master/README.md   "Autoloaded readme"
[inline-documentation]:       http://www.rubydoc.info/github/njonsson/autoloaded            "Autoloaded inline documentation"
