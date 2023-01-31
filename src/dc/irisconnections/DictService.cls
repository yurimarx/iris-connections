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

/// Description
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

}
