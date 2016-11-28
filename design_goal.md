RubyConf 2016 - To Clojure and back: writing and rewriting in Ruby by Phill MV
 https://www.youtube.com/watch?v=doZ0XAc9Wtc
 
 1. "value" objects
 tcrayford/values

 2. "manager" object
 controller: handles input
 model: value object. handles persistence(db query, save)
 manager: handles state

```
 class PackageManager
   attr_reader :platform, :release
   def initialize platform, release
     @platform = platform
     @release = release
   end
   # methods never modify inputs.
   # never set internal state
   def find_existing_packages package_list
     return Package.none if package_list.empty?
     query = Package.where platform: self.platform,
                           release: self.release
     query.search_qunique_fields(package_list.map(&:uniq_values))
   end
```
