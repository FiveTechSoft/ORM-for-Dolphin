#include "TDolphin.ch"
#include "hbclass.ch"

//----------------------------------------------------------------------------//

function Main()

   local oConnection := TDolphinSrv():New( "www.fivetechsoft.com",; // server
                                           "fivetech_orm",;         // username 
                                           "hborm",;                // password 
                                           3306,,;                  // port 
                                           "fivetech_orm" )         // database
   local oUsers := Users():New( oConnection, "users" ) // tableName
   
   ? oUsers:Invoices:Count()
   ? oUsers:Invoices:Items:Count()

   oConnection:End()

return nil

//----------------------------------------------------------------------------//

CLASS Users FROM HbModel

   DATA _Invoices PROTECTED
   
   METHOD New( oConnection, cTableName )

   METHOD Invoices()
   
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( oConnection, cTableName ) CLASS Users

   ::Super:New( oConnection, cTableName )
   
   ::_Invoices = Invoices():New( oConnection, "invoices" )
   
return Self

//----------------------------------------------------------------------------//

METHOD Invoices() CLASS Users

return ::_Invoices:Where( "user_id", ::oRs:Id )

//----------------------------------------------------------------------------//

CLASS Invoices FROM HbModel

   DATA _Items PROTECTED
   
   METHOD New( oConnection, cTableName )
   METHOD Items()

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( oConnection, cTableName ) CLASS Invoices

   ::Super:New( oConnection, cTableName )
   
   ::_Items = Items():New( oConnection, "items" )
   
return Self

//----------------------------------------------------------------------------//

METHOD Items() CLASS Invoices

return ::_Items:Where( "invoice_id", ::oRs:Id )

//----------------------------------------------------------------------------//

CLASS Items FROM HbModel

ENDCLASS

//----------------------------------------------------------------------------//

CLASS HbModel

   DATA   oConnection 
   DATA   cTableName
   DATA   oRs

   METHOD New( oConnection, cTableName )
   
   METHOD Count() INLINE ::oRs:RecCount()
   METHOD Where( cFieldName, uValue )
   METHOD First() INLINE ( ::oRs:GoTop(), Self )
   
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( oConnection, cTableName ) CLASS HbModel

   ::oConnection = oConnection
   ::cTableName  = cTableName
   
   ::oRs = oConnection:Query( "SELECT * FROM " + ::cTableName )
   
return Self   

//----------------------------------------------------------------------------//

METHOD Where( cFieldName, uValue ) CLASS HbModel

   ::oRs := ::oConnection:Query( "SELECT * FROM " + ::cTableName + ;
                                 " WHERE " + cFieldName + "=" + ClipValue2SQL( uValue ) )

return Self
                                     
//----------------------------------------------------------------------------//
      
