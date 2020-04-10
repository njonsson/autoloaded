# Version history for the *Autoloaded* project

## <a name="v1.6.0"></a>v1.6.0, Sun 4/05/2020

* Eliminate Ruby warnings about
  [*Binding#source_location*][Ruby-Core-Binding-source_location] (thanks to
  [@guss77][GitHub-user-guss77])

## <a name="v1.5.1"></a>v1.5.1, Wed 10/18/2017

* Eliminate Ruby warnings about undefined instance variables

## <a name="v1.5.0"></a>v1.5.0, Wed 2/22/2017

* Add support for Ruby load paths (`$:`) that contain one or more
  [*Pathname*][Ruby-Stdlib-Pathname] objects (thanks to
  [@ekampp][GitHub-user-ekampp])

## <a name="v1.4.1"></a>v1.4.1, Sat 1/24/2015

* Don’t warn about a *VERSION* constant presumably loaded by a *.gemspec*

## <a name="v1.3.0"></a>v1.3.0, Fri 12/26/2014

* Add support for relative class references with a new API

## <a name="v1.2.0"></a>v1.2.0, Fri 11/28/2014

* Add support for [JRuby][JRuby] (Ruby v2.x-compatible versions)

## <a name="v1.1.0"></a>v1.1.0, Tue 11/04/2014

* Correct/improve autoload behavior
  * Instead of returning the source **directory** path from
    [*Module#autoload?*][Ruby-Core-Module-autoload], return one or more matching
    source **file** path(s)
  * Use Ruby load path (`$:`) to handle relative source file paths
  * Explain *Module#autoload?* and
    [*Module#constants*][Ruby-Core-Module-constants] in the [readme][readme] and
    in [inline documentation][inline-documentation]

## <a name="v1.0.0"></a>v1.0.0, Wed 10/29/2014

* Add support for Ruby v2.0

## <a name="v0.0.3"></a>v0.0.3, Fri 10/24/2014

(First release)

[GitHub-user-ekampp]:                https://github.com/ekampp                                       "GitHub user @ekampp"
[GitHub-user-guss77]:                https://github.com/guss77                                       "GitHub user @guss77"
[JRuby]:                             https://www.jruby.org/
[Ruby-Core-Binding-source_location]: https://ruby-doc.org/core/Binding.html#method-i-source_location "‘Binding#source_location’ method in the Ruby Core Library"
[Ruby-Core-Module-autoload]:         https://ruby-doc.org/core/Module.html#method-i-autoload-3F      "‘Module#autoload’ method in the Ruby Core Library"
[Ruby-Core-Module-constants]:        https://ruby-doc.org/core/Module.html#method-i-constants        "‘Module#constants’ method in the Ruby Core Library"
[Ruby-Stdlib-Pathname]:              https://ruby-doc.org/stdlib/libdoc/pathname/rdoc/Pathname.html  "‘Pathname’ class in the Ruby Standard Library"
[readme]:                            https://github.com/njonsson/autoloaded/blob/master/README.md    "Autoloaded readme"
[inline-documentation]:              https://www.rubydoc.info/github/njonsson/autoloaded             "Autoloaded inline documentation"
