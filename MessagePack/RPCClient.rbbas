#tag Class
Protected Class RPCClient
Inherits TCPSocket
	#tag Event
		Sub Connected()
		  buffer = ""
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub DataAvailable()
		  buffer = buffer + ReadAll()
		  
		  ' extract every available packets
		  While process_data()
		  Wend
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub Error()
		  Dim req_id As Integer
		  
		  'If LastErrorCode = LostConnection Then
		  
		  ' start by timing out every pending request
		  For Each req_id  In pSleepingThreads.Keys
		    response_received(req_id, "error", "timeout")
		  Next
		  
		  For Each req_id In pCallbacks.Keys
		    response_received(req_id, "error", "timeout")
		  Next
		  
		  pRetryTimer = New RetryTimer(10000, AddressOf Connect, Timer.ModeSingle)
		  'Else
		  'Dim n As Integer = 42
		  'End
		  
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Function blocking_request(th as MPThread, service_name As String, method_name As String, ParamArray args As Variant) As Variant
		  Dim req_id As Integer = th.ThreadID
		  
		  th.error = Nil
		  th.return_value = Nil
		  
		  _send_request(req_id, service_name, method_name, args)
		  
		  pSleepingThreads.Value( req_id ) = th
		  
		  th.Suspend()
		  
		  If th.error <> Nil Then
		    Raise th.error
		  Else
		    Return th.return_value
		  End
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor()
		  // Calling the overridden superclass constructor.
		  // Note that this may need modifications if there are multiple constructor choices.
		  // Possible constructor calls:
		  // Constructor() -- From TCPSocket
		  // Constructor() -- From SocketCore
		  Super.Constructor
		  
		  pSleepingThreads = new Dictionary
		  pCallbacks = new Dictionary
		  pServices = new Dictionary
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function process_data() As Boolean
		  'Dim after As Double
		  Dim bs As New BinaryStream(buffer)
		  
		  ' first decode the header
		  Dim len As UInt32 = bs.ReadUInt32()
		  
		  ' check if we have everything
		  If bs.Length >= len + 4 Then
		    Dim data As String
		    ' Packet data
		    data = bs.Read(len)
		    
		    ' the rest
		    buffer = bs.Read(bs.Length)
		    
		    ' and process the data received
		    Dim cmd() As Variant
		    
		    cmd = MessagePack.decode(data)
		    If (cmd(0) = "reply") or (cmd(0) = "error")  Then
		      response_received(cmd(1), cmd(0), cmd(2))
		      Return True
		      
		    ElseIf cmd(0) = "call" Then
		      Try
		        Dim ret As Variant = run_service_method(cmd(2), cmd(3), cmd(4))
		        send_reply(cmd(1), ret)
		      Catch err As RuntimeException
		        send_error(cmd(1), "app_error", err.Message)
		      End
		      
		      Return True
		      
		      
		    End If
		  End If
		  
		  Return false
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub register_service(module_name As String, svc As Object)
		  
		  if pServices.HasKey(module_name) Then
		    Dim err As RuntimeException
		    err.Message = "Module already defined: " + module_name
		    Raise err
		  Else
		    pServices.Value(module_name) = svc
		  End
		  
		End Sub
	#tag EndMethod

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Sub ReplyReceived(req_id As Integer, ret As Variant, error As MessagePack . Error = Nil)
	#tag EndDelegateDeclaration

	#tag Method, Flags = &h21
		Private Sub response_received(request_id As Integer, type As String, value As Variant)
		  If pSleepingThreads.HasKey( request_id ) Then
		    Dim th As MessagePack.MPThread = pSleepingThreads.Value(request_id)
		    If type = "error" Then
		      Dim err As new Error(value)
		      th.error = err
		    Else
		      th.return_value = value
		    End
		    th.Resume
		    
		  ElseIf pCallbacks.HasKey(request_id) Then
		    Dim cb As ReplyReceived = pCallbacks.Value(request_id)
		    If type = "error" Then
		      cb.Invoke(request_id, Nil, value)
		    Else
		      cb.Invoke(request_id, value, Nil)
		    End
		    
		  End
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function run_service_method(module_name As String, method_name As String, args() As Variant) As Variant
		  If pServices.HasKey(module_name) Then
		    Dim svc As Object = pServices.Value(module_name)
		    Dim type As Introspection.TypeInfo = Introspection.GetType(svc)
		    
		    ' find the method
		    Dim method As Introspection.MethodInfo = Nil
		    
		    For Each method In type.GetMethods
		      If method_name = method.Name Then
		        Exit For
		      End
		    Next
		    
		    If method.Name = method_name Then
		      Return method.Invoke(svc, args)
		      
		    Else
		      Dim err As RuntimeException
		      err.Message = "Unknown method: " + method_name
		      Raise err
		    End
		    
		  Else
		    Dim err As RuntimeException
		    err.Message = "Unknown service: " + module_name
		    Raise err
		  End
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub send_error(req_id As Integer, type As String, msg As String)
		  Dim cmd(3) As Variant
		  
		  cmd(0) = "error"
		  cmd(1) = req_id
		  cmd(2) = type
		  cmd(3) = msg
		  
		  send_packet(cmd)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub send_packet(cmd() As Variant)
		  If IsConnected Then
		    Dim mb As New MemoryBlock(100)
		    Dim bs As New BinaryStream(mb)
		    
		    bs.LittleEndian = False
		    mb.LittleEndian = False
		    
		    ' keep space for the header
		    bs.Position = 4
		    
		    MessagePack.encode(bs, cmd)
		    
		    Dim len As Integer = Min( bs.Position, bs.Length )
		    
		    ' now fill the header
		    mb.UInt32Value(0) = len - 4
		    
		    self.Write( mb.StringValue(0, len) )
		    
		  Else
		    Raise New Error("offline")
		  End
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub send_reply(req_id As Integer, val As Variant)
		  Dim cmd(2) As Variant
		  
		  cmd(0) = "reply"
		  cmd(1) = req_id
		  cmd(2) = val
		  
		  send_packet(cmd)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub send_request_with_callback(req_id As Integer, cb As ReplyReceived, service_name As String, method_name As String, ParamArray args As Variant)
		  Dim cmd(4) As Variant
		  
		  cmd(0) = "call"
		  cmd(1) = req_id
		  cmd(2) = service_name
		  cmd(3) = method_name
		  cmd(4) = args
		  
		  pCallbacks.Value(req_id) = cb
		  
		  send_packet(cmd)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub _send_request(req_id As Integer, service_name As String, method_name As String, args() As Variant)
		  Dim cmd(4) As Variant
		  
		  cmd(0) = "call"
		  cmd(1) = req_id
		  cmd(2) = service_name
		  cmd(3) = method_name
		  cmd(4) = args
		  
		  send_packet(cmd)
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private buffer As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private pCallbacks As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private pRetryTimer As MessagePack.RetryTimer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private pServices As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private pSleepingThreads As Dictionary
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Address"
			Visible=true
			Group="Behavior"
			Type="String"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Port"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
