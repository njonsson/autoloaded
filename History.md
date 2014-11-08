# Version history for the _Autoloaded_ project

## <a name="v1.1.0"></a>v1.1.0, Tue 11/04/2013

* Correct/improve autoload behavior
  * Instead of returning the source **directory** path from
    [_Module#autoload?_][Ruby-Core-Module-autoload], return one or more matching
    source **file** path(s)
  * Use Ruby load path (`$:`) to handle relative source file paths
  * Explain _Module#autoload?_ and
    [_Module#constants_][Ruby-Core-Module-constants] in the [readme][readme] and
    in [inline documentation][inline-documentation]

## <a name="v1.0.0"></a>v1.0.0, Wed 10/29/2013

* Add support for Ruby v2.0

## <a name="v0.0.3"></a>v0.0.3, Fri 10/24/2014

(First release)

[Ruby-Core-Module-autoload]:  http://ruby-doc.org/core/Module.html#method-i-autoload-3F   "‘Module#autoload’ method in the Ruby Core Library"
[Ruby-Core-Module-constants]: http://ruby-doc.org/core/Module.html#method-i-constants     "‘Module#constants’ method in the Ruby Core Library"
[readme]:                     http://github.com/njonsson/autoloaded/blob/master/README.md "Autoloaded readme"
[inline-documentation]:       http://www.rubydoc.info/github/njonsson/autoloaded          "Autoloaded inline documentation"