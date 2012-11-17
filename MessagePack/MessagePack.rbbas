#tag Module
Protected Module MessagePack
	#tag Method, Flags = &h21
		Private Sub check_available_space(ByRef bs As BinaryStream, required_space As Integer)
		  bs.LittleEndian = False
		  
		  If bs.Length < ( bs.Position + required_space ) Then
		    bs.Length = bs.Length + Max(100, required_space)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function decode(ByRef data As String) As Variant
		  Dim bs As New BinaryStream(data)
		  
		  ' and now decode the packet
		  Return decode_item(bs)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function decode_array(ByRef bs As BinaryStream) As Variant()
		  'Dim type As Byte = bs.ReadByte()
		  'Dim len As Integer
		  'Dim ret() As Variant
		  '
		  'If type <> LIST Then
		  'Dim ex As New RuntimeException
		  'ex.Message = "wrong type"
		  'Raise ex
		  'End If
		  '
		  'len = bs.ReadUInt32()
		  '
		  'For n As Integer = 0 To len - 1
		  'ret.Append( decode_item(bs) )
		  'Next
		  '
		  'Return ret
		  '
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function decode_float(ByRef bs As BinaryStream) As Double
		  'Dim type As Byte = bs.ReadByte()
		  'If type <> MessagePack.Type.FLOAT Then
		  'Dim ex As New RuntimeException
		  'ex.Message = "wrong type"
		  'Raise ex
		  'End If
		  '
		  'Dim str As String = bs.Read(32)
		  '
		  '
		  'Return Val(str)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function decode_integer(ByRef bs As BinaryStream) As Variant
		  'Dim type As Byte = bs.ReadByte()
		  'Dim ret As Variant
		  '
		  'Select Case type
		  'Case SMALL_INT
		  'Dim n As Uint8 = bs.ReadByte()
		  'ret = n
		  '
		  'Case INT
		  'Dim n As Int32 = bs.ReadInt32()
		  'ret = n
		  '
		  'Else
		  'Dim ex As New RuntimeException
		  'ex.Message = "wrong type"
		  'Raise ex
		  '
		  'End Select
		  '
		  '
		  'Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function decode_item(ByRef bs As BinaryStream) As Variant
		  'Dim type As Byte = bs.ReadByte()
		  'Dim v, varr() As Variant
		  '
		  'bs.Position = bs.Position - 1
		  '
		  'Select Case type
		  '
		  'Case BINARY
		  'v = decode_binary(bs)
		  '
		  'Case FLOAT
		  'v = decode_float(bs)
		  '
		  'Case SMALL_INT, INT, SMALL_BIGNUM
		  'v = decode_integer(bs)
		  '
		  'Case SMALL_TUPLE, LARGE_TUPLE
		  'v = decode_tuple(bs)
		  '
		  'CASE LIST
		  'v = decode_list(bs)
		  '
		  'CASE NULL
		  'Return nil
		  '
		  'Case STRING
		  'v = decode_string(bs)
		  '
		  'End Select
		  '
		  'Return v
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function decode_map(ByRef bs As BinaryStream) As Dictionary
		  'Dim data() As Variant = decode_item(bs)
		  'Dim n As Integer
		  'Dim d As New Dictionary
		  '
		  'For n = 0 To data.Ubound
		  't = data(n)
		  '
		  'If t.Len <> 2 Then
		  'Dim err As New RuntimeException
		  'err.Message = "Invalid packet : pretends to be a dict but is not"
		  'Raise err
		  'End if
		  '
		  'd.Value( t.values(0) ) = t.values(1)
		  'Next
		  '
		  'Return d
		  '
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function decode_string(ByRef bs As BinaryStream) As String
		  'Dim type As Byte = bs.ReadByte()
		  'If type <> STRING Then
		  'Dim ex As New RuntimeException
		  'ex.Message = "wrong type"
		  'Raise ex
		  'End If
		  '
		  'Dim len As UInt16 = bs.ReadUInt16()
		  'Dim value As String = bs.Read(len, Encodings.UTF8)
		  '
		  'Return value
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode(ByRef buff As BinaryStream, val As Variant)
		  ' everything is in big-endian
		  buff.LittleEndian = False
		  
		  encode_item(buff, val)
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, b As Boolean)
		  '
		  'if true_atom = Nil Then
		  'true_atom = New MessagePack.Symbol("true")
		  'false_atom = New MessagePack.Symbol("false")
		  'End If
		  '
		  'encode_item(buff,  bert_atom)
		  'If b Then
		  'encode_item(buff, true_atom)
		  'Else
		  'encode_item(buff, false_atom)
		  'End If
		  '
		  '
		  '
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, d As Date)
		  '
		  'if time_atom = Nil Then
		  'time_atom = New MessagePack.Symbol("time")
		  'End If
		  '
		  'encode_item(buff,  bert_atom)
		  'encode_item(buff, time_atom)
		  '
		  'd.GMTOffset = 0
		  '' Convert to unix timestamp
		  'Dim stamp AS Double = d.TotalSeconds - 2082844800
		  '
		  'Dim mega As Int64 = stamp / 1000000
		  'Dim seconds As Int64 = stamp Mod 1000000
		  'Dim usec As Int64 = 0
		  '
		  'encode_item(buff, mega)
		  'encode_item(buff, seconds)
		  'encode_item(buff, usec)
		  '
		  '
		  '
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, ByRef d As Dictionary)
		  '
		  'if dict_atom = Nil Then
		  'dict_atom = New MessagePack.Symbol("dict")
		  'End If
		  '
		  'Dim t As New MessagePack.Tuple
		  '
		  't.Append( bert_atom )
		  't.Append(dict_atom)
		  '
		  'Dim parts() As Variant
		  '
		  'For Each k As Variant In d.Keys
		  'parts.Append( New MessagePack.Tuple(k, d.Value(k)) )
		  'Next
		  '
		  't.Append(parts)
		  'encode_item(buff, t)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, val As Double)
		  '
		  'check_available_space(buff, 5)
		  '
		  'Dim tmp As String = Replace(Format(val, "#.00000000000000000000e"), ",", ".")
		  'buff.WriteByte( FLOAT )
		  'buff.Write(tmp)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, n As Int32)
		  '
		  'Dim value As Int64 = n
		  'encode_item(buff, value)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, n As Int64)
		  'Dim MIN_INT As Integer = Bitwise.ShiftLeft(1, 27, 32) * -1
		  'Dim MAX_INT As Integer = Bitwise.ShiftLeft(1, 27, 32) - 1
		  '
		  'if n >= 0 and n <= 255 Then
		  'check_available_space(buff, 2)
		  'buff.WriteByte( SMALL_INT )
		  'buff.WriteByte( n )
		  '
		  'ElseIf n >= MIN_INT and n <= MAX_INT Then
		  'check_available_space(buff, 5)
		  'buff.WriteByte( INT )
		  'buff.WriteInt32(n)
		  '
		  'Else
		  'encode_bignum(buff, n)
		  'End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, list As MessagePack.List)
		  '
		  'check_available_space(buff, 4)
		  '
		  'buff.WriteUInt32( list.Len )
		  '
		  'For Each v As Variant In list.values
		  'encode_item(buff, v)
		  'Next
		  '
		  'check_available_space(buff, 1)
		  'buff.WriteByte( NULL )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, obj As Object)
		  'If obj IsA Dictionary Then
		  'Dim d As Dictionary = Dictionary(obj)
		  'encode_item(buff, d)
		  '
		  'ElseIf obj IsA MessagePack.Symbol Then
		  'encode_item(buff, MessagePack.Symbol(obj))
		  '
		  'ElseIf obj IsA MessagePack.Tuple Then
		  'encode_item(buff, MessagePack.Tuple(obj))
		  '
		  'ElseIf  obj IsA MessagePack.List Then
		  'encode_item(buff, MessagePack.List(obj))
		  'End If
		  '
		  '
		  '
		  ''Dim ci As Introspection.TypeInfo = Introspection.GetType(obj)
		  ''
		  ''If ci.FullName = "MessagePack.Symbol" Then
		  ''encode_item(buff, MessagePack.Symbol(obj))
		  ''ElseIf ci.FullName = "MessagePack.Tuple" Then
		  ''encode_item(buff, MessagePack.Tuple(obj))
		  ''End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, str As String)
		  '
		  'check_available_space(buff, 3 + str.LenB)
		  '
		  ''buff.WriteByte( STRING )
		  ''buff.WriteUInt16( str.LenB )
		  'buff.WriteByte( BINARY )
		  'buff.WriteUInt32( str.LenB )
		  'buff.Write( str )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, n As UInt64)
		  'Dim MIN_INT As Integer = Bitwise.ShiftLeft(1, 27, 32) * -1
		  'Dim MAX_INT As Integer = Bitwise.ShiftLeft(1, 27, 32) - 1
		  '
		  'if n >= 0 and n <= 255 Then
		  'check_available_space(buff, 2)
		  'buff.WriteByte( SMALL_INT )
		  'buff.WriteByte( n )
		  '
		  'ElseIf n >= MIN_INT and n <= MAX_INT Then
		  'check_available_space(buff, 5)
		  'buff.WriteByte( INT )
		  'buff.WriteInt32(n)
		  '
		  'Else
		  'encode_bignum(buff, n)
		  'End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, val As Variant)
		  Select Case val.Type
		  Case Variant.TypeDouble
		    encode_item(buff, val.DoubleValue)
		    
		  Case Variant.TypeString
		    encode_item(buff, val.StringValue)
		    
		  Case Variant.TypeInteger
		    encode_item(buff, val.IntegerValue)
		    
		  Case Variant.TypeLong
		    encode_item(buff, val.Int64Value)
		    
		  Case Variant.TypeObject
		    encode_item(buff, val.ObjectValue)
		    
		  Else
		    
		    if BitwiseAnd(val.Type, Variant.TypeArray) = Variant.TypeArray Then
		      Dim v_arr() As Variant = val
		      Dim size As Integer = v_arr.Ubound + 1
		      
		      if size + 1 <= 15 Then
		        ' 1001XXXX (XX = size)
		        buff.WriteByte( BitOr(&b10010000, BitwiseAnd(&b00001111, size)) )
		        
		      ElseIf size <= Pow(2, 16) - 1 Then
		        buff.WriteUInt8( UInt8(Type.ARRAY16) )
		        buff.WriteUInt16( size )
		        
		      Else
		        buff.WriteByte( UInt8(Type.ARRAY32) )
		        buff.WriteUInt32( size )
		      End
		      
		      For Each v As Variant In v_arr
		        encode_item(buff, v)
		      Next
		      
		    End If
		    
		  End Select
		End Sub
	#tag EndMethod


	#tag Enum, Name = Type, Type = UInt8, Flags = &h21
		UINT8 = &hCC
		  UINT16 = &hCD
		  UINT32 = &hCE
		  UINT64 = &hCF
		  INT8 = &hD0
		  INT16 = &hD1
		  INT32 = &hD2
		  INT64 = &hD3
		  NULL = &hC0
		  BOOL_TRUE = &hC3
		  BOOL_FALSE = &hC2
		  FLOAT = &hCA
		  DOUBLE = &hCB
		  RAW16 = &hDA
		  RAW32 = &hDB
		  ARRAY16 = &hDC
		  ARRAY32 = &hDD
		  MAP16 = &hDE
		MAP32 = &hDF
	#tag EndEnum


	#tag ViewBehavior
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
End Module
#tag EndModule
