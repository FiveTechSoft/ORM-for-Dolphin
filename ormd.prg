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
   local n, m
   
   for n = 1 to oUsers:OrderBy( "lastname" ):Count()
      ? oUsers:oRs:LastName
      oUsers:Next()
   next

   ? oUsers:Find( 1 ):Invoices:Sum( "amount" )
   
   ? "Number of invoices for: " + AllTrim( oUsers:oRs:FirstName ) + " " + ;
                                  AllTrim( oUsers:oRs:LastName ) + " --> " + ;
                                  AllTrim( Str( oUsers:Invoices:Count() ) )
   
   for n = 1 to oUsers:Invoices:Count()
      ? "   Invoice id: " + Str( oUsers:Invoices:oRs:id )
         for m = 1 to oUsers:Invoices:Items:Count()
            ? "      Item " + AllTrim( Str( m ) ) + ": " + ;
              AllTrim( oUsers:Invoices:Items:oRs:Description )
            oUsers:Invoices:Items:Next()
         next   
      oUsers:Invoices():Next()
   next   

   oConnection:End()

return nil

//----------------------------------------------------------------------------//

CLASS Users FROM HbModel

   DATA _Invoices        PROTECTED
   
   METHOD New( oConnection, cTableName )

   METHOD Invoices()
   
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( oConnection, cTableName ) CLASS Users

   ::Super:New( oConnection, cTableName )
   
   ::_Invoices = Invoices():New( oConnection, "invoices" ) // tableName
   
return Self

//----------------------------------------------------------------------------//

METHOD Invoices() CLASS Users

   if ::nLastId != ::oRs:Id
      ::nLastId = ::oRs:Id
      ::_Invoices:Where( "user_id", ::oRs:Id )
   endif

return ::_Invoices

//----------------------------------------------------------------------------//

CLASS Invoices FROM HbModel

   DATA _Items PROTECTED
   
   METHOD New( oConnection, cTableName )
   METHOD Items()

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( oConnection, cTableName ) CLASS Invoices

   ::Super:New( oConnection, cTableName )
   
   ::_Items = Items():New( oConnection, "items" )   // tableName
   
return Self

//----------------------------------------------------------------------------//

METHOD Items() CLASS Invoices

   if ::nLastId != ::oRs:Id
      ::nLastId = ::oRs:Id
      ::_Items:Where( "invoice_id", ::oRs:Id )
   endif

return ::_Items

//----------------------------------------------------------------------------//

CLASS Items FROM HbModel

ENDCLASS

//----------------------------------------------------------------------------//

CLASS HbModel

   DATA   oConnection 
   DATA   cTableName
   DATA   oRs
   DATA   nLastId   INIT 0 PROTECTED

   METHOD New( oConnection, cTableName )
   
   METHOD Count() INLINE ::oRs:RecCount()
   METHOD Find( nId ) INLINE ( ::oRs:Seek( nId, "id" ), Self )
   METHOD Where( cFieldName, uValue )
   METHOD First() INLINE ( ::oRs:GoTop(), Self )
   METHOD Next()  INLINE ( ::oRs:Skip( 1 ), Self )
   METHOD Prev()  INLINE ( ::oRs:Skip( -1 ), Self )
   METHOD Last()  INLINE ( ::oRs:GoBottom(), Self )
   METHOD OrderBy( cFieldName, lDescent ) 
   METHOD Sum( cFieldName )
   METHOD Sql()   INLINE ::oRs:cQuery
   
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
      
METHOD OrderBy( cFieldName, lDescent ) CLASS HbModel

   if lDescent == nil
      lDescent = .F.
   endif   

   ::oRs:SetOrder( cFieldName + If( ! lDescent, " ASC", " DESC" ), .T. )
   
return Self

//----------------------------------------------------------------------------//

METHOD Sum( cFieldName ) CLASS HbModel

   local oOldRs := ::oRs, nResult
   
   ::oRs := ::oConnection:Query( "SELECT SUM(" + cFieldName + ") " + ;
            SubStr( ::oRs:cQuery, At( "FROM", ::oRs:cQuery ) ) )
            
   nResult = If( ::oRs:RecCount() > 0, ::oRs:FieldGet( 1 ), 0 )
   
   ::oRs = oOldRs

return nResult
                                     
//----------------------------------------------------------------------------//
