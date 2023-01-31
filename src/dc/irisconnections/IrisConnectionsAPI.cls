Class dc.irisconnections.IrisConnectionsAPI Extends %CSP.REST
{

Parameter Version = "1.0.0";

Parameter CHARSET = "utf-8";

Parameter CONVERTINPUTSTREAM = 1;

Parameter CONTENTTYPE = "application/json";

Parameter HandleCorsRequest = 1;

Parameter PAGESIZE As INTEGER = 20;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<!-- Server Info -->
<Route Url="/" Method="GET" Call="GetInfo" Cors="true"/>
<!-- Get namespace list -->
<Route Url="/namespaces" Method="GET" Call="GetNamespaceList"/>
<!-- Get class list -->
<Route Url="/classes" Method="GET" Call="GetClassList" Cors="true"/>
<!-- Swagger specs -->
<Route Url="/_spec" Method="GET" Call="SwaggerSpec" />
<!-- GET method to return JSON for a given person id-->
<Route Url="/persons/:id" Method="GET" Call="GetPerson"/>
<!-- Update a person with id-->
<Route Url="/persons/:id" Method="PUT" Call="UpdatePerson"/>
<!-- Delete a person with id-->
<Route Url="/persons/:id" Method="DELETE" Call="DeletePerson"/>
<!-- Create a person-->
<Route Url="/persons/" Method="POST" Call="CreatePerson"/>
<!-- Create random persons-->
<Route Url="/persons/gen/:amount" Method="POST" Call="CreateRandomPersons"/>


</Routes>
}

/// PersonsREST general information
ClassMethod GetInfo() As %Status
{
  SET version = ..#Version
  SET info = {
    "version": (version)
  }
  RETURN ..%ProcessResult($$$OK, info)
}

/// Retreive all the records of dc.irisconnections.Person
ClassMethod GetAllPersons() As %Status
{

    #dim tSC As %Status = $$$OK

    Set rset = ##class(dc.irisconnections.Person).ExtentFunc()

    Set %response.ContentType = ..#CONTENTTYPEJSON
    Write "["
    if rset.%Next() {
        Set person = ##class(dc.irisconnections.Person).%OpenId(rset.ID)    
        Do person.%JSONExport()
    }
    While rset.%Next() {   
        Write ","
        Set person = ##class(dc.irisconnections.Person).%OpenId(rset.ID)    
        Do person.%JSONExport()
    }
    Write "]"
    Quit tSC
}

/// List current namespaces
ClassMethod GetNamespaceList() As %Status
{

    #dim tSC As %Status = $$$OK

    Set %response.ContentType = ..#CONTENTTYPEJSON

    Set tSC = ##class(dc.irisconnections.DictService).GetNamespaceList(.result)

    Write result.%ToJSON()
    
    Quit tSC
}

/// List current classes
ClassMethod GetClassList() As %Status
{

    #dim tSC As %Status = $$$OK

    Set %response.ContentType = "application/json"
    Set %response.Headers("Access-Control-Allow-Origin")="*" 
    
    Set tSC = ##class(dc.irisconnections.DictService).GetClassList(.result)

    Write result.%ToJSON()
    
    Quit tSC
}

/// Return one record fo dc.irisconnections.Person
ClassMethod GetPerson(id As %Integer) As %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException


    #; Set the response header to plain text
    Set %response.ContentType = ..#CONTENTTYPEJSON

    Set person = ##class(dc.irisconnections.Person).%OpenId(id)

    If '$IsObject(person) Quit ..ReportHttpStatusCode(404)

    Do person.%JSONExport()

    Quit tSC
}

/// Creates a new dc.irisconnections.Person record
ClassMethod CreatePerson() As %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    Set person = ##class(dc.irisconnections.Person).%New()
    Set data=%request.Content


    $$$TOE(tSC,person.%JSONImport(data))
    $$$TOE(tSC,person.%Save())

    Set %response.Status = 204
    Set %response.ContentType = ..#CONTENTTYPEJSON
    //d data.%ToJSON()
    Do person.%JSONExport()

    Quit tSC
}

/// Update a record in dc.irisconnections.Person with id
ClassMethod UpdatePerson(id As %Integer) As %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    Set person = ##class(dc.irisconnections.Person).%OpenId(id)
    If '$IsObject(person) Return ..ReportHttpStatusCode(404)
    Set data=%request.Content

    $$$TOE(tSC,person.%JSONImport(data))
    $$$TOE(tSC,person.%Save())

    Set %response.Status = 200

    Set %response.ContentType = ..#CONTENTTYPEJSON
    Do person.%JSONExport()

    Quit tSC
}

/// Delete a record with id in dc.irisconnections.Person
ClassMethod DeletePerson(id As %Integer) As %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    Set person = ##class(dc.irisconnections.Person).%OpenId(id)
    If '$IsObject(person) Return ..ReportHttpStatusCode(404)

    $$$TOE(tSC,person.%DeleteId(id))

    Set %response.Status = 200

    Set %response.ContentType = ..#CONTENTTYPEJSON

    Quit tSC
}

ClassMethod CreateRandomPersons(amount As %Integer) As %Status
{
#dim tSC As %Status = $$$OK
    Set %response.ContentType = ..#CONTENTTYPEJSON

    Try {
        set status = ##class(dc.irisconnections.Person).AddTestData(amount)
        $$$ThrowOnError(status)
        Set message = "Created "_amount_" random persons in Sample.Person data"
    } Catch(ex) {
        Set tSC = ex.Code
    }
    Return tSC
}

ClassMethod SwaggerSpec() As %Status
{
  Set tSC = ##class(%REST.API).GetWebRESTApplication($NAMESPACE, %request.Application, .swagger)
  Do swagger.info.%Remove("x-ISC_Namespace")
  Set swagger.basePath = "/iris-connections"
  Set swagger.info.title = "InterSystems IRIS REST CRUD demo"
  Set swagger.info.version = "0.1"
  Set swagger.host = "localhost:52773"
  Return ..%ProcessResult($$$OK, swagger)
}

ClassMethod %ProcessResult(pStatus As %Status = {$$$OK}, pResult As %DynamicObject = "") As %Status [ Internal ]
{
  #dim %response As %CSP.Response
  SET tSC = $$$OK
  IF $$$ISERR(pStatus) {
    SET %response.Status = 500
    SET tSC = ..StatusToJSON(pStatus, .tJSON)
    IF $isobject(tJSON) {
      SET pResult = tJSON
    } ELSE {
      SET pResult = { "errors": [ { "error": "Unknown error parsing status code" } ] }
    }
  } 
  ELSEIF pStatus=1 {
    IF '$isobject(pResult){
      SET pResult = {
      }
    }
  }
  ELSE {
    SET %response.Status = pStatus
    SET error = $PIECE(pStatus, " ", 2, *)
    SET pResult = {
      "error": (error)
    }
  }
  
  IF pResult.%Extends("%Library.DynamicAbstractObject") {
    WRITE pResult.%ToJSON()
  }
  ELSEIF pResult.%Extends("%JSON.Adaptor") {
    DO pResult.%JSONExport()
  }
  ELSEIF pResult.%Extends("%Stream.Object") {
    DO pResult.OutputToDevice()
  }
  
  QUIT tSC
}

ClassMethod ReportHttpStatusCode(pHttpStatus, pSC As %Status = {$$$OK}) As %Status
{
  Set %response.Status=pHttpStatus
  
  If $$$ISERR(pSC) Do ..outputStatus(pSC)
  /*
  If (+pHttpStatus>=400) {
    Set %response.ContentType = "application/json"
    SET pResult = {
      "error": ($PIECE(pHttpStatus, " ", 2, *))
    }
    Return ..%ProcessResult($$$OK, pResult)
  }*/
      
  Return $$$OK
}

}
