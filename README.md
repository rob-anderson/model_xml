Introduction
============

model_xml is a small gem which helps in the conversion of ruby objects to xml.  It is designed with ActiveRecord objects in mind, but should work with any Ruby object.

Installation
============

gem 'model_xml' in your gemfile, or gem install model_xml

If you are using Rails, just require model_xml any time after ActiveRecord has loaded - the bottom of your environment.rb file is fine.  Otherwise, require model_xml, then include ModelXML in your object.

Usage
=====

Take a look at ActiveRecord's baked in to_xml method first.  If it meets your requirements, obviously just use that.  If not, read on.

The simplest usage method is just to declare the list of fields you want in your model's xml representation, like this:

    class Foo < ActiveRecord::Base
      model_xml :first_name, :last_name, :dob
    end

