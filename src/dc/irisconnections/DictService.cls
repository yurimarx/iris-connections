/// Dict service relationship service
Class dc.irisconnections.DictService
{

/// Description
ClassMethod GetNamespaceList(Output namespaceList As %DynamicArray) As %Status
{
    Set tSC = $$$OK

    Set namespaceList = ##class(%DynamicArray).%New()
    
    Try {
        Do ##class(%SYS.Namespace).ListAll(.result)
        Set key=$ORDER(result(""))
        While (key '= "") {
            Set namespaceItem = ##class(%DynamicObject).%New()
            Set namespaceItem.namespace = key
            Do namespaceList.%Push(namespaceItem)
            Set key = $ORDER(result(key))
        }
    } Catch ex {
        Set tSC=ex.AsStatus()
    }

    Return tSC
}

/// Get class dependencies list
ClassMethod GetClassList(Output classList As %DynamicArray) As %Status
{
    Set tSC = $$$OK

    Set classList = ##class(%DynamicArray).%New()

    Try {
        Set stmt=##class(%SQL.Statement).%New()
        Set status = stmt.%PrepareClassQuery("%Dictionary.ClassDefinition","Summary")
        Set rset=stmt.%Execute()
        
        While rset.%Next() {
            If (($FIND(rset.%Get("Name"), "%") '= 2) &&
                ($FIND(rset.%Get("Name"), "Ens.") '= 5) &&
                ($FIND(rset.%Get("Name"), "EnsLib.") '= 8) &&
                ($FIND(rset.%Get("Name"), "EnsPortal.") '= 11) &&
                (rset.%Get("System") = "0")) {
                Set classItem = ##class(%DynamicObject).%New()
                Set classItem.name = rset.%Get("Name")
                Set classItem.super = rset.%Get("Super")
                Set classItem.persistent = rset.%Get("Persistent")
                Set classItem.serial = rset.%Get("Serial")
                Set classItem.sqltablename = rset.%Get("SqlTableName")
                Do ##class(%Compiler.UDL.TextServices).GetTextAsString($NAMESPACE, rset.%Get("Name"), .text)
                Set classItem.content = text
                Set classItem.description = ""
                Set classItem.dependencies = ##class(%DynamicArray).%New()
                Set classItem.properties = ##class(%DynamicArray).%New()
                Set classItem.methods = ##class(%DynamicArray).%New()

                Set classDetails = ##class(%Dictionary.ClassDefinition).%OpenId(classItem.name)
                Set classItem.description = classDetails.Description

                Set count = classDetails.Properties.Count()
                For i = 1:1:count {
                    Set propertyItem = ##class(%DynamicObject).%New()
                    Set propertyItem.name = classDetails.Properties.GetAt(i).Name
                    Set propertyItem.type = classDetails.Properties.GetAt(i).Type
                    Do classItem.properties.%Push(propertyItem)
                }

                Set count = classDetails.Methods.Count()
                For i = 1:1:count {
                    Set methodItem = ##class(%DynamicObject).%New()
                    Set methodItem.name = classDetails.Methods.GetAt(i).Name
                    Set methodItem.type = classDetails.Methods.GetAt(i).ReturnType
                    Do classItem.methods.%Push(methodItem)
                }

                Do classList.%Push(classItem)
            }
        }

        Set itCurrent = classList.%GetIterator()

        While itCurrent.%GetNext(.currentKey, .currentValue) {
            
            Set itList = classList.%GetIterator()

            While itList.%GetNext(.listKey, .listValue) {
                If ((currentValue.name '= listValue.name) &&
                    ($FIND(currentValue.content, listValue.name) > 0)) {
                    Set dependencyItem = ##class(%DynamicObject).%New()
                    Set dependencyItem.name = listValue.name
                    Do classList.%Get(currentKey).dependencies.%Push(dependencyItem)
                }
            }
        }

        Set itRemoveContent = classList.%GetIterator()

        While itRemoveContent.%GetNext(.removeKey, .removeValue) {
            Set classList.%Get(removeKey).content = ""
        }
    
    } Catch ex {
        Set tSC=ex.AsStatus()
    }
    
    Quit status
}

/// Get Markdown class inventory
ClassMethod GetInventoryInMarkdown(Output mdContent As %Stream.GlobalCharacter) As %Status
{
    Set tSC = $$$OK 

    Set mdContent = ##class(%Stream.GlobalCharacter).%New()

    Do mdContent.WriteLine("# Classes Inventory")
    
    Set classList = ##class(%DynamicArray).%New()

    Try {
        Set stmt=##class(%SQL.Statement).%New()
        Set status = stmt.%PrepareClassQuery("%Dictionary.ClassDefinition","Summary")
        Set rset=stmt.%Execute()
        
        While rset.%Next() {
            If (($FIND(rset.%Get("Name"), "%") '= 2) &&
                ($FIND(rset.%Get("Name"), "Ens.") '= 5) &&
                ($FIND(rset.%Get("Name"), "EnsLib.") '= 8) &&
                ($FIND(rset.%Get("Name"), "EnsPortal.") '= 11) &&
                (rset.%Get("System") = "0")) {

                Do ##class(%Compiler.UDL.TextServices).GetTextAsString($NAMESPACE, rset.%Get("Name"), .text)
                
                Set classDetails = ##class(%Dictionary.ClassDefinition).%OpenId(rset.%Get("Name"))

                Do mdContent.WriteLine("## "_rset.%Get("Name"))
                
                Do mdContent.WriteLine("### Description: "_classDetails.Description)
                
                If rset.%Get("Super") '= "" {
                    Do mdContent.WriteLine("### Super: "_rset.%Get("Super"))
                }

                If rset.%Get("Persistent") '= "0" {
                    Do mdContent.WriteLine("### Persistent: Yes")
                } Else {
                    Do mdContent.WriteLine("### Persistent: No")
                }

                If rset.%Get("Serial") '= "0" {
                    Do mdContent.WriteLine("### Serial: Yes")
                } Else {
                    Do mdContent.WriteLine("### Serial: No")
                }

                If rset.%Get("SqlTableName") '= "" {
                    Do mdContent.WriteLine("### SQL Table Name: "_rset.%Get("SqlTableName"))
                }

                Set countProperties = classDetails.Properties.Count()

                If countProperties > 0 {
                    Do mdContent.WriteLine("### Class properties: ")
                }

                For i = 1:1:countProperties {
                    Do mdContent.WriteLine("- "_classDetails.Properties.GetAt(i).Name_": "_classDetails.Properties.GetAt(i).Type)
                }

                Set countMethods = classDetails.Methods.Count()
                
                If countMethods > 0 {
                    Do mdContent.WriteLine("### Class methods: ")
                }

                For j = 1:1:countMethods {
                    Do mdContent.WriteLine("- "_classDetails.Methods.GetAt(j).Name_": "_classDetails.Methods.GetAt(j).ReturnType)
                }

                Do mdContent.WriteLine("")
            }
        }

    } Catch ex {
        Set tSC=ex.AsStatus()
    }
    
    Quit status
}

}
