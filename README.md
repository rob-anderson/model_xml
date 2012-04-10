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

    class User < ActiveRecord::Base
      model_xml :first_name, :last_name, :dob
    end

Then user.to_xml gives:

    <user>
      <first_name>John</first_name>
      <last_name>Jones</last_name>
      <dob>1970-12-23</dob>
    </user>

Note that (unlike ActiveRecords's to_xml) the field names can be any method in your object, not just database columns - eg

    class User < ActiveRecord::Base
      model_xml :full_name, :dob

      def full_name
        "#{first_name} {last+name}"
      end
    end

behaves as expected:

    <user>
      <full_name>John Jones</full_name>
      <dob>1970-12-23</dob>
    </user>

You can even declare a formatting proc on the fly, like this:

    class User < ActiveRecord::Base
      model_xml [:full_name, proc {|u| "#{u.first_name} #{u.last_name}"], :dob
    end

which would give the same result.

For more complicated setups, you can use block notation like this:

    class User < ActiveRecord::Base
      model_xml do
        full_name proc {|u| "#{u.first_name} #{u.last_name}"}
        dob
        password
        last_logged_in
      end
    end

Finally, you can declare named blocks using block notation like this:

    class User < ActiveRecord::Base
      model_xml :first_name, :last_name
      model_xml :personal_details do
        dob
        password
        last_logged_in
      end
    end

By default named blocks are excluded from the xml, so user.to_xml gives

    <user>
      <first_name>John</first_name>
      <last_name>Jones</last_name>
    </user>

but can be included explicitly - so user.to_xml(:personal_details => true) gives

    <user>
      <first_name>John</first_name>
      <last_name>Jones</last_name>
      <dob>1970-12-23</dob>
      <password>foo</password>
      <last_logged_in>2012-04-10</last_logged_in>
    </user>

Source
======

Source is on github https://github.com/rob-anderson/model_xml

Bugs
====

Send bugs or comments to me rob.anderson@paymentcardsolutions.co.uk
