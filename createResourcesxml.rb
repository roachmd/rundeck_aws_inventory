#!/usr/bin/ruby

#=begin 
# Useage: export ZONE="us-west-2" STACK="NONPROD" RUNDECKFILE="resources.xml"; ./createResourcesxml.rb
#  
# = Required GEMs
# require 'aws-sdk'
#

require 'aws-sdk'
#
# = Environment Vars
# 
aws_zone = ENV['ZONE'] || "us-east-2"
aws_stacks = ENV['STACK'] || "NONPROD"
rundeck_resource_file = ENV['RUNDECKFILE'] || "../resources/resources.xml"

# = Global Variables
total_processed = 0
total_written = 0

# = Methods

# Return a real aws environment tag or reports an Empty Tag.
def return_environment (tag_environment)
    #
     if tag_environment[0] != nil
	   return tag_environment[0].value 
     else
	   return "Empty_Tag"
     end
end # return_Environment
# Returns a real aws name tag or reports an Empty Tag.
def return_name (tag_name)
    if tag_name[0] != nil
        return tag_name[0].value 
     else
       return "Empty_Tag"
    end
end # return_Name
# Writes Header to Rundeck resources.xml file
def print_rundeck_header (a_file)
   a_file.puts %q[<?xml version="1.0" encoding="UTF-8"?>]
   a_file.puts "\n"
   a_file.puts %q[<project>]
end
# Writes Footer to Rundeck resources.xml file
def print_rundeck_footer (a_file)
  a_file.puts %q[</project>]
  a_file.close
end
# Verify basic env are set.
def verify_env (zone)
    if zone == nil
        puts "-- Please set AWS availability zone."
        puts %q[-- USEAGE: export ZONE="us-west-2"; ./buildrundeckResources.rb ]
        abort("-- Aborting rundeck file build.")
    end
end
# Writes host line formatted for Rundeck Consumption
def print_rundeck_hosts(ec2,a_file,aws_stacks,total_processed,total_written)
   environment = ""
   name = ""
    ec2.instances.each do |i|
     total_processed = total_processed + 1
     name = return_name(i.tags.select{|tag| tag.key == 'Name'})
     environment = return_environment(i.tags.select{|tag| tag.key == "ENVIRONMENT"})
     if aws_stacks == "NONPROD"
        if environment.upcase  == "DEV" || environment.upcase  == "STAGING" || environment.upcase == "Empty_Tag"
	     a_file.puts %Q[<node name="#{name}" description="Rundeck server node" tags="#{environment}" hostname="#{i.private_ip_address}" osArch="#{i.architecture}" osFamily="unix" osName="Linux" osVersion="#{i.image_id}" username="ubuntu"/>]
         total_written = total_written + 1
        end
     else
        if environment.upcase  == "PRODUCTION" 
	     a_file.puts %Q[<node name="#{name}" description="Rundeck server node" tags="#{environment}" hostname="#{i.private_ip_address}" osArch="#{i.architecture}" osFamily="unix" osName="Linux" osVersion="#{i.image_id}" username="ubuntu"/>]
         total_written = total_written + 1
        end
     end 
    end
    return total_processed, total_written
end
# Prints out the number of instances found and number of instances written to resources.xml
def put_stats(total_processed, total_written)
  puts "-- Stats"
  puts "-- Total Instances Processed #{total_processed}"
  puts "-- Total Written to resources.xml #{total_written}"
  puts "-- Processing Complete"  
end

# = Main
#
verify_env(aws_zone)
a_file = File.new("#{rundeck_resource_file}", "w")
ec2 = Aws::EC2::Resource.new(region: "#{aws_zone}")
if a_file
  puts "-- Running Mode"
  puts "-- Processing #{aws_stacks} hosts in #{aws_zone} availability zone"
  print_rundeck_header(a_file)
  total_processed, total_written = print_rundeck_hosts(ec2,a_file, aws_stacks, total_processed, total_written) 
  print_rundeck_footer(a_file)
else
   puts "Unable to open file!"
end
putStats(total_processed, total_written)
# = end
