<h2>{request:get-parameter('id', '')}</h2>  

{for $parameter in $parameters  

   return   
   <h2>{request:get-parameter('', '')}</h2>  

}   

let $type := if (matches($edweb:p_type, 'person'))then (<h1>PERSON</h1>)  
else(<h1> FUCK </h1>)   
