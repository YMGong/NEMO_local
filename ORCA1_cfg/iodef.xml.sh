# Find out if we run attached or detached (default is detached)
has_config xios:attached && using_server=false || using_server=true
has_config xios:detached && using_server=true

# Find out if we are using OASIS and set using_oasis accordingly
has_config oasis && using_oasis=true || using_oasis=false

# Buffer allocation mode for XIOS2, either "memory" or "performance". In
# "memory" mode, XIOS will try to use buffers as small as possible. In
# "performance" mode, XIOS will ensure that all active fields can be buffered
# without flushes. This is default since it allows more asynchronism and thus
# better performance at the cost of being quite memory hungry
optimal_buffer_size="performance"

cat << EOF
<?xml version="1.0"?>
<simulation> 

<!-- ============================================================================================ -->
<!-- XIOS context                                                                                 -->
<!-- ============================================================================================ -->

  <context id="xios" >

      <variable_definition>
	
	  <variable id="info_level"                type="int">10</variable>

	  <variable id="using_server"              type="bool">$using_server</variable>
	  <variable id="using_oasis"               type="bool">$using_oasis</variable>
	  <variable id="oasis_codes_id"            type="string" >oceanx</variable>

	  <variable id="optimal_buffer_size"       type="string" >$optimal_buffer_size</variable>
	
      </variable_definition>
  </context>

<!-- ============================================================================================ -->
<!-- NEMO  CONTEXT add and suppress the components you need                                       -->
<!-- ============================================================================================ -->

  <context id="nemo" src="./context_nemo.xml"/>       <!--  NEMO       -->

</simulation>
EOF
