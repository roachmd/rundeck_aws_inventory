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
awsZone = ENV['ZONE'] || "us-east-2"
awsStacks = ENV['STACK'] || "NONPROD"
rundeckResourceFile = ENV['RUNDECKFILE'] || "../resources/resources.xml"

# = Global Variables
totalProcessed = 0
totalWritten = 0

# = Methods

# Return a real aws environment tag or reports an Empty Tag.
def return_Environment (tagEnvironment)
    #
     if tagEnvironment[0] != nil
	   return tagEnvironment[0].value 
     else
	   return "Empty_Tag"
     end
end # return_Environment
# Returns a real aws name tag or reports an Empty Tag.
def return_Name (tagName)
    if tagName[0] != nil
        return tagName[0].value 
     else
       return "Empty_Tag"
    end
end # return_Name
# Writes Header to Rundeck resources.xml file
def printRundeckHeader (aFile)
   aFile.puts %q[<?xml version="1.0" encoding="UTF-8"?>]
   aFile.puts "\n"
   aFile.puts %q[<project>]
end
# Writes Footer to Rundeck resources.xml file
def printRundeckFooter (aFile)
  aFile.puts %q[</project>]
  aFile.close
end
# Verify basic env are set.
def verifyEnv (zone,awsStacks)
    if zone == nil
        puts "-- Please set AWS availability zone."
        puts %q[-- USEAGE: export ZONE="us-west-2"; ./buildrundeckResources.rb ]
        abort("-- Aborting rundeck file build.")
    end
end
# Writes host line formatted for Rundeck Consumption
def printRundeckHosts(ec2,aFile,awsStacks,totalProcessed,totalWritten)
   environment = ""
   name = ""
    ec2.instances.each do |i|
     totalProcessed = totalProcessed + 1
     name = return_Name(i.tags.select{|tag| tag.key == 'Name'})
     environment = return_Environment(i.tags.select{|tag| tag.key == "ENVIRONMENT"})
     if awsStacks == "NONPROD"
        if environment.upcase  == "DEV" || environment.upcase  == "STAGING" || environment.upcase == "Empty_Tag"
	     aFile.puts %Q[<node name="#{name}" description="Rundeck server node" tags="#{environment}" hostname="#{i.private_ip_address}" osArch="#{i.architecture}" osFamily="unix" osName="Linux" osVersion="#{i.image_id}" username="ubuntu"/>]
         totalWritten = totalWritten + 1
        end
     else
        if environment.upcase  == "PRODUCTION" 
	     aFile.puts %Q[<node name="#{name}" description="Rundeck server node" tags="#{environment}" hostname="#{i.private_ip_address}" osArch="#{i.architecture}" osFamily="unix" osName="Linux" osVersion="#{i.image_id}" username="ubuntu"/>]
         totalWritten = totalWritten + 1
        end
     end 
    end
    return totalProcessed, totalWritten
end
# Prints out the number of instances found and number of instances written to resources.xml
def putStats(totalProcessed, totalWritten)
  puts "-- Stats"
  puts "-- Total Instances Processed #{totalProcessed}"
  puts "-- Total Written to resources.xml #{totalWritten}"
  puts "-- Processing Complete"  
end

# = Main
#
verifyEnv(awsZone,awsStacks)
aFile = File.new("#{rundeckResourceFile}", "w")
ec2 = Aws::EC2::Resource.new(region: "#{awsZone}")
if aFile
  puts "-- Running Mode"
  puts "-- Processing #{awsStacks} hosts in #{awsZone} availability zone"
  printRundeckHeader(aFile)
  totalProcessed, totalWritten = printRundeckHosts(ec2,aFile, awsStacks, totalProcessed, totalWritten) 
  printRundeckFooter(aFile)
else
   puts "Unable to open file!"
end
putStats(totalProcessed, totalWritten)
# = end
