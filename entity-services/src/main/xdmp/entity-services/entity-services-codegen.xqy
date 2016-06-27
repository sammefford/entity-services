(:
 Copyright 2002-2016 MarkLogic Corporation.  All Rights Reserved. 

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
:)
xquery version "1.0-ml";


(: This module supports code generation for entity services.
 : This module has no public API.  See entity-services.xqy for
 : the public interface.
 :)
module namespace es-codegen = "http://marklogic.com/entity-services-codegen";

import module namespace esi = "http://marklogic.com/entity-services-impl"
    at "entity-services-impl.xqy";

import module namespace functx   = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

declare namespace es = "http://marklogic.com/entity-services";
declare namespace tde = "http://marklogic.com/xdmp/tde";

declare private function es-codegen:casting-function-name(
    $datatype as xs:string
) as xs:string
{
    if ($datatype eq "iri")
    then "sem:iri"
    else "xs:" || $datatype
};


declare private function es-codegen:comment(
    $comment-text as xs:string
) as xs:string
{
    concat('(: ', 
        functx:pad-string-to-length(
            $comment-text, 
            " ",
            max( ( (string-length($comment-text)+4), 80) )),
           ' :)&#10;')
};

declare function es-codegen:conversion-module-generate(
    $entity-type as map:map
) as document-node()
{
    let $info := map:get($entity-type, "info")
    let $title := map:get($info, "title")
    let $prefix := lower-case(substring($title,1,1)) || substring($title,2)
    let $version:= map:get($info, "version")
    let $definitions := map:get($entity-type, "definitions")
    let $base-uri := esi:resolve-base-uri($info)
    return
document {
<conversion-module>xquery version "1.0-ml";

(: 
 : This module was generated by MarkLogic Entity Services. 
 : The source entity type document was {$title}-{$version}
 :
 : To use this module, examine how you wish to extract data from sources,
 : and modify the various extract-instance-{{X}} functions to 
 : create the instances you wish.
 :
 : You may wish to/need to alter
 : 1.  values.  For example, creating duration values from decimal months.
 : 2.  references.  This conversion module assumes you want to denormalize 
 :     instances when storing them in documents.  You may choose to remove 
 :     code that denormalizes, and just include reference values in your instances 
 :     instead.
 : 3.  Source XPath expressions.  The data coming into the extract-instance-{{X}} 
 :     functions will probably not be exactly what this module predicts.
 :
 : After modifying this file, put it in your project for deployment to the modules 
 : database of your application, and check it into your source control system.
 :
 : Modification History:
 :   Generated at timestamp: {fn:current-dateTime()}
 :   Persisted by AUTHOR
 :   Date: DATE
 :)
module namespace {$prefix} = "{$base-uri}{$title}-{$version}";

import module namespace es = "http://marklogic.com/entity-services" 
    at "/MarkLogic/entity-services/entity-services.xqy";


(:
 :  extract-instance-{{entity-type}} functions 
 :
 :  These functions take together take a source document and create a nested
 :  map structure from it.
 :  The resulting map is used by instance-to-canonical-xml to create documents
 :  in the database.
 :  
 :  It is expected that an implementer will edit at least XPath expressions in
 :  the extraction functions.  It is less likely that you will want to edit
 :  the instance-to-canonical-xml or envelope functions.
 :)
{ 
    for $entity-type-key in map:keys(map:get($entity-type, "definitions"))
    return 
    <extract-instance>
(:~
 : Creates a map:map representation of an entity instance from some source
 : document.
 : @param $source-node  A document or node that contains data for populating a {$entity-type-key}
 : @return A map:map instance that holds the data for this entity type.
 :)
declare function {$prefix}:extract-instance-{$entity-type-key}(
    $source-node as node()
) as map:map
{{
    json:object()
        (: This line identifies the type of this instance.  Do not change it. :)
        =>map:with('$type', '{ $entity-type-key }')
        (: This line adds the original source document as an attachment.
         : If this entity type is not the root of a document, you should remove this.
         : If the source document is JSON, use 
         : =>map:with('$attachments', xdmp:quote($source-node))
         : because you cannot preserve JSON nodes with the XML envelope verbatim.
         :)
        =>map:with('$attachments', $source-node)
        (: The following lines are generated from the '{ $entity-type-key }' entity type 
         : You need to ensure that all of the property paths are correct for your source
         : data to populate instances.  The general pattern is
         : =>map:with('keyName', casting-function($source-node/path/to/data/in/the/source))
         : but you may also wish to convert values
         : =>map:with('dateKeyName', 
         :            xdmp:parse-dateTime("[Y0001]-[M01]-[D01]T[h01]:[m01]:[s01].[f1][Z]", 
         :            $source-node/path/to/data/in/the/source))
         : You can also implement lookup functions, 
         : =>map:with('lookupKey', 
         :            cts:search( collection('customers'), 
         :                        string($source-node/path/to/lookup/key))/id
         : or populate the instance with constants.
         : =>map:with('constantValue', 10)
         : Once you've customized this function, write a test with expected 
         : inputs, and a test instance document
         : created with es:entity-type-get-test-instances($entity-type)
         :)
    {
    (: Begin code generation block :)
    let $this-type := map:get($definitions, $entity-type-key)
    let $properties-map := map:get($this-type, "properties")
    let $properties-keys := map:keys($properties-map)
    for $property-key in map:keys($properties-map)
    let $is-required := $property-key = 
            ( map:get($this-type, "primaryKey"), json:array-values( map:get($this-type, "required")) )
    let $is-array := 
            map:get(map:get($properties-map, $property-key), "datatype") 
            eq "array"
    let $property-datatype := esi:resolve-datatype($entity-type, $entity-type-key, $property-key)
    let $casting-function-name := es-codegen:casting-function-name($property-datatype)
    let $wrap-if-array := function($str) {
            if ($is-array and $is-required)
            then concat("json:to-array(", $str, " ! ", $casting-function-name, "(.) )")
            else
            if ($is-array)
            then concat($prefix, ":extract-array(", $str, ", ", $casting-function-name, "#1)")
            else concat($casting-function-name, "(", $str, ")")
        }
    let $ref :=
        if ($is-array)
        then map:get(map:get(map:get($properties-map, $property-key), "items"), "$ref")
        else map:get(map:get($properties-map, $property-key), "$ref")
    let $path-to-property := concat("$source-node/", $entity-type-key, "/", $property-key)
    let $property-comment :=
        if (empty($ref))
        then ""
        else if (contains($ref, "#/definitions"))
        then es-codegen:comment("The following property is a local reference.")
        else concat(
        es-codegen:comment('The following property assigment comes from an external reference.'),
        " ", (: why this is needed for alignment is a mystery so far :)
        es-codegen:comment('Its generated value probably requires developer attention.'))
    let $value :=
        if (empty($ref))
        then 
            $wrap-if-array($path-to-property)
        else 
            if(contains($ref, "#/definitions"))
            then
            concat("&#10;            if (", $path-to-property, "/element())",
                   "&#10;            then ",  $prefix, ":extract-array(",
                    $path-to-property, ", ", $prefix, ":extract-instance-", replace($ref, "#/definitions/", ""), "#1)",
                   "&#10;            else ", $casting-function-name, "(",
                   $path-to-property,
                   ")")
            else
               concat(
                $path-to-property, "/node()")
                
    (: if a property is required, use map:with to force inclusion :)
    let $function-call-string :=
        if ($is-required)
        then "       =>map:with("
        else "    =>es:optional("
    return
    concat($property-comment,
           $function-call-string, 
           functx:pad-string-to-length("'" || $property-key || "',", " ", max((  (string-length($property-key)+4), 25) )+1 ),
           $value, 
           ")&#10;"
          )
    (: end code generation block :)
    }
}};
</extract-instance>/text()
}


(:~
 : This function includes an array if there are items to put in it.
 : If there are no such items, then it returns an empty sequence.
 : TODO EA-4? move to es: module
 :)
declare function {$prefix}:extract-array(
    $path-to-property as item()*,
    $fn as function(*)
) as json:array?
{{
    if (empty($path-to-property))
    then ()
    else json:to-array($path-to-property ! $fn(.))
}};


(:~
 : Turns an entity instance into an XML structure.
 : This out-of-the box implementation traverses a map structure
 : and turns it deterministically into an XML tree.
 : Using this function as-is should be sufficient for most use
 : cases, and will play well with other generated artifacts.
 : @param $entity-instance A map:map instance returned from one of the extract-instance
 :    functions.
 : @return An XML element that encodes the instance.
 :)
declare function {$prefix}:instance-to-canonical-xml(
    $entity-instance as map:map
) as element()
{{
    (: Construct an element that is named the same as the Entity Type :)
    element {{ map:get($entity-instance, "$type") }}  {{
        for $key in map:keys($entity-instance)
        let $instance-property := map:get($entity-instance, $key)
        where ($key castable as xs:NCName and $key ne "$type")
        return
            typeswitch ($instance-property)
            (: This branch handles embedded objects.  You can choose to prune
               an entity's representation of extend it with lookups here. :)
            case json:object+ 
                return
                    for $prop in $instance-property
                    return element {{ $key }} {{ {$prefix}:instance-to-canonical-xml($prop) }}
            (: An array can also treated as multiple elements :)
            case json:array
                return 
                    for $val in json:array-values($instance-property)
                    return
                        if ($val instance of json:object)
                        then element {{ $key }} {{ {$prefix}:instance-to-canonical-xml($val) }}
                        else element {{ $key }} {{ $val }}
            (: A sequence of values should be simply treated as multiple elements :)
            case item()+
                return 
                    for $val in $instance-property
                    return element {{ $key }} {{ $val }}
            default return element {{ $key }} {{ $instance-property }}
    }}
}};


(: 
 : Wraps a canonical instance (returned by instance-to-canonical-xml())
 : within an envelope patterned document, along with the source
 : document, which is stored in an attachments section.
 : @param $entity-instance an instance, as returned by an extract-instance
 : function
 : @return A document which wraps both the canonical instance and source docs.
 :)
declare function {$prefix}:instance-to-envelope(
    $entity-instance as map:map
) as document-node()
{{
    document {{
        element es:envelope {{
            element es:instance {{
                element es:info {{
                    element es:title {{ map:get($entity-instance,'$type') }},
                    element es:version {{ "{$version}" }}
                }},
                {$prefix}:instance-to-canonical-xml($entity-instance)
            }},
            element es:attachments {{
                map:get($entity-instance, "$attachments") 
            }}
        }}
    }}
}};

</conversion-module>/text()
}


};



declare private function es-codegen:comment-for-conversion(
    $target-property-name as xs:string,
    $target-entity-type as map:map,
    $source-entity-type as map:map
) as xs:string
{
    es-codegen:comment("boo")
};

declare private function es-codegen:value-for-conversion(
    $source-model as map:map,
    $target-model as map:map,
    $target-entity-type-name as xs:string,
    $target-property-name as xs:string,
    $module-prefix
) as xs:string
{
    let $target-entity-type := $target-model
        =>map:get("definitions")
        =>map:get($target-entity-type-name)
    let $target-property := $target-entity-type
        =>map:get("properties")
        =>map:get($target-property-name)
    let $source-properties := $source-model
        =>map:get("definitions")
        =>map:get($target-entity-type-name)    (: this function is only called with matching types/props :)
        =>map:get("properties")
    let $is-missing-source := not($target-property-name = map:keys($source-properties))
    let $source-correlate := map:get($source-properties, $target-property-name)
    let $target-is-scalar-array := 
        map:get($target-property, "datatype") eq 'array' and map:get($target-property, "items")=>map:contains("datatype")
    let $source-is-scalar-array := 
        map:get($source-correlate, "datatype") eq 'array' and map:get($source-correlate, "items")=>map:contains("datatype")
    let $properties-correlate := not($target-is-scalar-array) and not($source-is-scalar-array) (: TODO and not ref :)
    let $is-array-from-scalar := $target-is-scalar-array and not($source-is-scalar-array)
    let $is-array-from-array := $target-is-scalar-array and $source-is-scalar-array
    let $is-scalar-from-array := not($target-is-scalar-array) and $source-is-scalar-array

    let $target-datatype := esi:resolve-datatype($target-model, $target-entity-type-name, $target-property-name)
    let $casting-function-name := es-codegen:casting-function-name($target-datatype)
    let $is-required := $target-property-name = 
            ( map:get($target-entity-type, "primaryKey"), json:array-values( map:get($target-entity-type, "required")) )
    let $path-to-property := concat("$source-node/", $target-entity-type-name, "/", $target-property-name)
        

    let $_ := xdmp:log(( "SSS", $target-property, $source-correlate))

    
    let $comment :=
        if ($is-missing-source)
        then es-codegen:comment("The following property was missing from the source type")
        else if ($is-scalar-from-array)
        then es-codegen:comment("Warning: potential data loss, truncated array.")
        else ()
    let $function-call-string :=
        if ($is-required)
        then "    =>   map:with("
        else "    =>es:optional("
    let $property-padding := 
        functx:pad-string-to-length("'" || $target-property-name || "',", " ", max((  (string-length($target-property-name)+4), 25) )+1 )
    let $value :=
        (: case one -- missing source :)
        if ($is-missing-source)
        then ' () '
        else if ($properties-correlate)
        then concat($casting-function-name, "(", $path-to-property, ")")
        else 
        if ($is-array-from-scalar)
        then 
            if ($is-required)
            then concat("json:to-array(", $path-to-property, " ! ", $casting-function-name, "(.) )")
            else concat($module-prefix, ":extract-array(", $path-to-property, ", ", $casting-function-name, "#1)")
        else if ($is-scalar-from-array)
        then concat($casting-function-name, "( fn:head(", $path-to-property, ") )")
               
        else if ($is-array-from-array)
        then 'equivarray'
        else '"not implemented"'

    return
        concat($comment,
            $function-call-string, 
            $property-padding,
            $value, 
            ")&#10;"
          )
    
};
    

declare function es-codegen:version-comparison-generate(
    $source-model as map:map,
    $target-model as map:map
) as document-node()
{
    let $target-info := map:get($target-model, "info")
    let $target-title := map:get($target-info, "title")
    let $target-prefix := lower-case(substring($target-title,1,1)) || substring($target-title,2)
    let $target-version:= map:get($target-info, "version")
    let $target-definitions := map:get($target-model, "definitions")
    let $target-entity-type-names := map:keys($target-definitions)
    let $target-base-uri := esi:resolve-base-uri($target-info)

    let $source-info := map:get($source-model, "info")
    let $source-title := map:get($source-info, "title")
    let $source-prefix := lower-case(substring($source-title,1,1)) || substring($source-title,2)
    let $source-version:= map:get($source-info, "version")
    let $source-definitions := map:get($source-model, "definitions")
    let $source-base-uri := esi:resolve-base-uri($source-info)

    let $module-prefix := $target-prefix || "-from-" || $source-prefix
    let $module-namespace := concat(
        $target-base-uri,
        $target-title,
        "-" ,
        $target-version,
        "-from-",
        $source-title,
        "-",
        $source-version)

    return document {
<comparison-module>xquery version "1.0-ml";
module namespace {$module-prefix} = "{$module-namespace}";

import module namespace es = "http://marklogic.com/entity-services" 
    at "/MarkLogic/entity-services/entity-services.xqy";

(: 
 : This module was generated by MarkLogic Entity Services. 
 : Its purpose is to create instances of entity types
 : defined in
 : $tar
 : from documents that were persisted 
 : according to entity type
 : $source
 :
 : Modification History:
 :   Generated at timestamp: {fn:current-dateTime()}
 :   Persisted by AUTHOR
 :   Date: DATE
 :)

{ 
    for $entity-type-key in $target-entity-type-names
    return 
    <convert-instance>
(:~
 : Creates a map:map instance representation of the target entity type
 : from a document that contains the source entity instance.
 : @param $source-node  A document or node that contains data conforming to the
 : source entity type
 : @return A map:map instance that holds the data for this entity type.
 :)
declare function {$module-prefix}:convert-instance-{$entity-type-key}(
    $source-node as node()
) as map:map
{{
    json:object()
(: The following line identifies the type of this instance.  Do not change it. :)
        =>map:with('$type', '{ $entity-type-key }')
{es-codegen:comment("The following lines are generated from the '"
                     || $entity-type-key || 
                     "' entity type.")}
    {
    (: Begin code generation block :)
    let $this-type := map:get($target-definitions, $entity-type-key)
    let $properties-map := map:get($this-type, "properties")
    let $properties-keys := map:keys($properties-map)
    for $property-key in map:keys($properties-map)
    let $path-to-property := concat("$source-node/", $entity-type-key, "/", $property-key)
    let $source-entity-type := map:get($source-definitions, $entity-type-key)
    let $source-properties := map:get($source-entity-type, "properties")
    return
        es-codegen:value-for-conversion($source-model, $target-model, $entity-type-key, $property-key, $module-prefix)
    (: end code generation block :)
    }
}};
    </convert-instance>/text(),

    (: Make comments for removed ET types :)
    for $removed-entity-type-key in map:keys($source-definitions)
    where not( $removed-entity-type-key = $target-entity-type-names)
    return
    <removed-type>
(: Entity type {$removed-entity-type-key} is in source document
 : but not in target document.
 : The following XPath expressions should get values from the source
 : instances but there is no specified target
 :
 :)
    </removed-type>/text()

}

(:~
 : This function includes an array if there are items to put in it.
 : If there are no such items, then it returns an empty sequence.
 : TODO EA-4? move to es: module
 :)
declare function {$module-prefix}:extract-array(
    $path-to-property as item()*,
    $fn as function(*)
) as json:array?
{{
    if (empty($path-to-property))
    then ()
    else json:to-array($path-to-property ! $fn(.))
}};



</comparison-module>/text()
    }
};

