# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

# syd
Station.create!(:name=>"Sydney",:lat=>-33.86,:long=>151.21,:height=>39.0,:bom=>1,:url=>"http://www.bom.gov.au/fwo/IDN60901/IDN60901.94768.json")

# melb
Station.create!(:name=>"Melbourne",:lat=>-37.81,:long=>144.97,:height=>31.15,:bom=>1,:url=>"http://www.bom.gov.au/fwo/IDV60901/IDV60901.94868.json")

# canb
Station.create!(:name=>"Canberra",:lat=>-35.31,:long=>149.20,:height=>577.05,:bom=>1,:url=>"http://www.bom.gov.au/fwo/IDN60903/IDN60903.94926.json")

# bris
Station.create!(:name=>"Brisbane",:lat=>-27.48,:long=>153.04,:height=>8.13,:bom=>1,:url=>"http://www.bom.gov.au/fwo/IDQ60901/IDQ60901.94576.json")

# hobart
Station.create!(:name=>"Hobart",:lat=>-42.89,:long=>147.33,:height=>50.5,:bom=>1,:url=>"http://www.bom.gov.au/fwo/IDT60901/IDT60901.94970.json")

# ade
Station.create!(:name=>"Adelaide",:lat=>-34.92,:long=>138.62,:height=>48.0,:bom=>1,:url=>"http://www.bom.gov.au/fwo/IDS60901/IDS60901.94675.json")

# darwin
Station.create!(:name=>"Darwin",:lat=>-12.42,:long=>130.89,:height=>30.4,:bom=>1,:url=>"http://www.bom.gov.au/fwo/IDD60901/IDD60901.94120.json")

# perth
Station.create!(:name=>"Perth",:lat=>-31.92,:long=>115.87,:height=>24.9,:bom=>1,:url=>"http://www.bom.gov.au/fwo/IDW60901/IDW60901.94608.json")
