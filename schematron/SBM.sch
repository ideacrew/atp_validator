<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns="http://purl.oclc.org/dsdl/schematron"
            xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:doc="http://hix.cms.gov/0.1/documentation"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            queryBinding="xslt2">
   <sch:title>Account Transfer Constraints</sch:title>

   <sch:extends href="./AccountTransfer-runtime.sch"/>

   <sch:pattern id="sbm-business">
      <sch:rule context="hix-core:PersonAugmentation/hix-core:PersonIncome[hix-core:IncomeCategoryCode = 'Wages']">
         <sch:assert test="exists(./../hix-core:PersonEmploymentAssociation/hix-core:Employer)">
           Wage type incomes require an employer.
         </sch:assert>
      </sch:rule>
   </sch:pattern>
</sch:schema>
