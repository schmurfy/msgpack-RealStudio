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
		  Dim dataType As Byte = bs.ReadByte()
		  Dim ret() As Variant
		  
		  If BitAnd(&b11110000, dataType) = &b10010000 Then
		    Dim size As UInt8 = BitAnd(&b00001111, dataType)
		    Redim ret(size - 1)
		    For n As UInt8 = 0 To size - 1
		      ret(n) = decode_item(bs)
		    Next
		    
		  ElseIf dataType = UInt8(Type.ARRAY16) Then
		    Dim size As UInt16 = bs.ReadUInt16()
		    Redim ret(size - 1)
		    For n As UInt16 = 0 To size - 1
		      ret(n) = decode_item(bs)
		    Next
		    
		  ElseIf dataType = UInt8(Type.ARRAY32) Then
		    Dim size As UInt32 = bs.ReadUInt32()
		    Redim ret(size - 1)
		    For n As UInt32 = 0 To size - 1
		      ret(n) = decode_item(bs)
		    Next
		    
		    
		  Else
		    invalid_type()
		  End
		  
		  Return ret
		  
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
		  Dim dataType As Byte = bs.ReadByte()
		  
		  ' positive
		  If dataType = UInt8(Type.UINT8) Then
		    Return bs.ReadUInt8()
		    
		  Elseif dataType = UInt8(Type.UINT16) Then
		    Return bs.ReadUInt16()
		    
		  Elseif dataType = UInt8(Type.UINT32) Then
		    REturn bs.ReadUInt32()
		    
		    'Elseif dataType = UInt8(Type.UINT64) Then
		    'Return bs.ReadUInt64()
		    
		  ElseIf BitAnd(&b10000000, dataType) = &b00000000 Then
		    Return dataType
		  End
		  
		  
		  ' negative --------
		  If BitAnd(&b11100000, dataType) = &b11100000 Then
		    bs.Position = bs.Position - 1
		    Return bs.ReadInt8()
		    
		  Elseif dataType = UInt8(Type.INT8) Then
		    Return bs.ReadInt8()
		    
		  ElseIf dataType = UInt8(Type.INT16) Then
		    Return bs.ReadInt16()
		    
		  ElseIf dataType = UInt8(Type.INT32) Then
		    Return bs.ReadInt32()
		    
		  End
		  
		  invalid_type()
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function decode_item(ByRef bs As BinaryStream) As Variant
		  Dim dataType As Byte = bs.ReadByte()
		  
		  bs.Position = bs.Position - 1
		  
		  ' strings
		  If (dataType = UInt8(Type.RAW16)) or (dataType = UInt8(Type.RAW32)) then
		    Return decode_string(bs)
		  ElseIf BitAnd(&b11100000, dataType) = &b10100000 Then
		    Return decode_string(bs)
		  End
		  
		  ' positive integers
		  If (dataType >= UInt8(Type.UINT8)) and (dataType <= UInt8(Type.UINT64)) Then
		    Return decode_integer(bs)
		  ElseIf BitAnd(&b10000000, dataType) = &b00000000 Then
		    Return decode_integer(bs)
		  End
		  
		  ' negative integers
		  If (dataType >= UInt8(Type.INT8)) and (dataType <= UInt8(Type.INT64)) Then
		    Return decode_integer(bs)
		  ElseIf BitAnd(&b11100000, dataType) = &b11100000 Then
		    Return decode_integer(bs)
		  End
		  
		  ' array
		  If (dataType >= UInt8(Type.ARRAY16)) and (dataType <= UInt8(Type.ARRAY32)) Then
		    Return decode_array(bs)
		  ElseIf BitAnd(&b11110000, dataType) = &b10010000 Then
		    Return decode_array(bs)
		  End
		  
		  invalid_type()
		  
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
		  Dim dataType As Byte = bs.ReadByte()
		  
		  If dataType = UInt8(Type.RAW16) Then
		    Dim size As UInt16 = bs.ReadUInt16()
		    Return bs.Read(size)
		    
		  Elseif dataType = UInt8(Type.RAW32) Then
		    Dim size As UInt32 = bs.ReadUInt32()
		    Return bs.Read(size)
		    
		  ElseIf BitAnd(&b11100000, dataType) = &b10100000 Then
		    Dim size As UInt8 = BitAnd(&b00011111, dataType)
		    Return bs.Read(size)
		  Else
		    invalid_type()
		  End
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode(ByRef buff As BinaryStream, val As Variant)
		  ' everything is in big-endian
		  buff.LittleEndian = False
		  
		  encode_item(buff, val)
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub encode_integer(ByRef buff As BinaryStream, v As Variant)
		  If Abs(v) <> v Then
		    if v >= -127 Then
		      Dim n As Int8 = v.IntegerValue
		      encode_item(buff, n)
		      
		    ElseIf v > - Pow(2, 15) Then
		      Dim n As Int16 = v.IntegerValue
		      encode_item(buff, n)
		      
		    ElseIf v > - Pow(2, 31) Then
		      encode_item(buff, v.Int32Value)
		      
		    Else
		      invalid_type()
		    End
		  Else
		    If v < Pow(2, 8) Then
		      Dim n As UInt8 = v.IntegerValue
		      encode_item(buff, n)
		      
		    ElseIf v < Pow(2, 16) Then
		      Dim n As UInt16 = v.IntegerValue
		      encode_item(buff, n)
		      
		    ElseIf v < Pow(2, 32) Then
		      encode_item(buff, v.UInt32Value)
		      
		      'ElseIf v < Pow(2, 64) Then
		      'encode_item(buff, v.UInt64Value)
		    Else
		      invalid_type()
		    end
		  End
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
		  
		  check_available_space(buff, 9)
		  
		  buff.WriteUInt8( UInt8(Type.DOUBLE)  )
		  buff.WriteDouble(val)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, n As Int16)
		  buff.WriteUInt8( UInt8(Type.INT16) )
		  buff.WriteInt16(n)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, n As Int32)
		  buff.WriteUInt8( UInt8(Type.INT32) )
		  buff.WriteInt32(n)
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
		Sub encode_item(ByRef buff As BinaryStream, n As Int8)
		  
		  If n >= -32 Then
		    buff.WriteInt8(n)
		    
		  Else
		    buff.WriteUInt8( UInt8(Type.INT8) )
		    buff.WriteInt8(n)
		    
		  End
		  
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
		  
		  Dim len As Integer = str.LenB
		  
		  If len <= 31 Then
		    buff.WriteUInt8( BitOr(&b10100000, BitAnd(&b00011111, len)) )
		    
		  ElseIf len < Pow(2, 16) Then
		    buff.WriteUInt8( UInt8(Type.RAW16) )
		    buff.WriteUInt16(len)
		    
		  ElseIf len < Pow(2, 32) Then
		    buff.WriteUInt8( UInt8(Type.RAW32) )
		    buff.WriteUInt32(len)
		    
		  end
		  
		  buff.Write(str)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, n As UInt16)
		  
		  buff.WriteUInt8( UInt8(Type.UINT16) )
		  buff.WriteUInt16(n)
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, n As UInt32)
		  
		  buff.WriteUInt8( UInt8(Type.UINT32) )
		  buff.WriteUInt32(n)
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, n As UInt64)
		  
		  buff.WriteUInt8( UInt8(Type.UINT64) )
		  buff.WriteUInt64(n)
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, n As UInt8)
		  
		  If n <= 127 Then
		    buff.WriteUInt8(n)
		    
		  Else
		    buff.WriteUInt8( UInt8(Type.UINT8) )
		    buff.WriteUInt8(n)
		    
		  End
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub encode_item(ByRef buff As BinaryStream, val As Variant)
		  
		  If val.Type = Variant.TypeDouble Then
		    encode_item(buff, val.DoubleValue)
		    
		  ElseIf val.Type = Variant.TypeNil Then
		    buff.WriteUInt8(&hC0)
		    
		  ElseIf val.Type = Variant.TypeBoolean Then
		    If val.BooleanValue Then
		      buff.WriteUInt8(&hC3)
		    Else
		      buff.WriteUInt8(&hC2)
		    End
		    
		  ElseIf val.Type = Variant.TypeString Then
		    encode_item(buff, val.StringValue)
		    
		  ElseIf val.Type = Variant.TypeInteger Then
		    encode_integer(buff, val)
		    
		  ElseIf val.Type = Variant.TypeLong Then
		    encode_integer(buff, val)
		    
		  ElseIf val.Type = Variant.TypeObject Then
		    encode_item(buff, val.ObjectValue)
		    
		  ElseIf BitwiseAnd(val.Type, Variant.TypeArray) = Variant.TypeArray Then
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
		    
		  Else
		    invalid_type()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub invalid_type()
		  Dim ex As New RuntimeException
		  ex.Message = "wrong type"
		  Raise ex
		  
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
