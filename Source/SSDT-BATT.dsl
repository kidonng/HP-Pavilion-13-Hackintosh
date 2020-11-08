DefinitionBlock ("", "SSDT", 2, "KID", "BATT", 0) {
    External (_SB.PCI0.LPCB.EC0, DeviceObj)
    External (_SB.GBFE, MethodObj)
    External (_SB.PBFE, MethodObj)
    External (_SB.BAT0, DeviceObj)
    External (_SB.BAT0.XPBI, MethodObj)
    External (_SB.BAT0.XPBS, MethodObj)
    External (_SB.PCI0.LPCB.EC0.XMWR, MethodObj)
    External (_SB.PCI0.LPCB.EC0.XMRD, MethodObj)
    External (_SB.PCI0.LPCB.EC0.MBNH, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.BVLB, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.BVHB, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SW2S, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.BACR, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.MBST, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.ECOK, IntObj)
    External (_SB.PCI0.LPCB.EC0.MUT0, MutexObj)
    External (_SB.PCI0.LPCB.EC0.SMB0, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMW0, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMD0, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMST, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMCM, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMAD, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMPR, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.BCNT, FieldUnitObj)
    External (_SB.BAT0.DTPY, IntObj)
    External (_SB.BAT0.PBIF, PkgObj)
    External (_SB.BAT0.FABL, IntObj)
    External (_SB.BAT0.PBST, PkgObj)
    External (_SB.BAT0.UPUM, MethodObj)
    
    Method (B1B2, 2, NotSerialized)
    {
        Return ((Arg0 | (Arg1 << 0x08)))
    }
    
    Method (W16B, 3, NotSerialized)
    {
        Arg0 = Arg2
        Arg1 = (Arg2 >> 0x08)
    }

    Method (RE1B, 1, NotSerialized)
    {
        OperationRegion (ERM2, EmbeddedControl, Arg0, One)
        Field (ERM2, ByteAcc, NoLock, Preserve)
        {
            BYTE,   8
        }

        Return (BYTE)
    }
    
    Method (RECB, 2, Serialized)
    {
        Arg1 = ((Arg1 + 0x07) >> 0x03)
        Name (TEMP, Buffer (Arg1){})
        Arg1 += Arg0
        Local0 = Zero
        While ((Arg0 < Arg1))
        {
            TEMP [Local0] = RE1B (Arg0)
            Arg0++
            Local0++
        }

        Return (TEMP)
    }

    Method (WE1B, 2, NotSerialized)
    {
        OperationRegion (ERM2, EmbeddedControl, Arg0, One)
        Field (ERM2, ByteAcc, NoLock, Preserve)
        {
            BYTE,   8
        }

        BYTE = Arg1
    }
    
    Method (WECB, 3, Serialized)
    {
        Arg1 = ((Arg1 + 0x07) >> 0x03)
        Name (TEMP, Buffer (Arg1){})
        TEMP = Arg2
        Arg1 += Arg0
        Local0 = Zero
        While ((Arg0 < Arg1))
        {
            WE1B (Arg0, DerefOf (TEMP [Local0]))
            Arg0++
            Local0++
        }
    }

    Scope (\_SB.PCI0.LPCB.EC0) {
        OperationRegion(ERM0, EmbeddedControl, Zero, 0xFF)
        Field(ERM0, ByteAcc, NoLock, Preserve) {
            Offset (0x70), 
            BAD0, 8,    // BADC
            BAD1, 8,
            BFC0, 8,    // BFCC
            BFC1, 8,
            Offset(0x83),
            MCU0, 8,    // MCUR
            MCU1, 8,
            MBR0, 8,    // MBRM
            MBR1, 8,
            MBC0, 8,    // MBCV
            MBC1, 8
        }
        
        Field(ERM0, ByteAcc, NoLock, Preserve) {
            Offset (0x04),
            MW00, 8,    // SMW0
            MW01, 8
        }
        
        Method (SMRD, 4, NotSerialized)
            {
            If (_OSI("Darwin")) {
                If (!ECOK)
                {
                    Return (0xFF)
                }

                If ((Arg0 != 0x07))
                {
                    If ((Arg0 != 0x09))
                    {
                        If ((Arg0 != 0x0B))
                        {
                            If ((Arg0 != 0x47))
                            {
                                If ((Arg0 != 0xC7))
                                {
                                    Return (0x19)
                                }
                            }
                        }
                    }
                }

                Acquire (MUT0, 0xFFFF)
                Local0 = 0x04
                While ((Local0 > One))
                {
                    SMST &= 0x40
                    SMCM = Arg2
                    SMAD = Arg1
                    SMPR = Arg0
                    Local3 = Zero
                    While (!Local1 = (SMST & 0xBF))
                    {
                        Sleep (0x02)
                        Local3++
                        If ((Local3 == 0x32))
                        {
                            SMST &= 0x40
                            SMCM = Arg2
                            SMAD = Arg1
                            SMPR = Arg0
                            Local3 = Zero
                        }
                    }

                    If ((Local1 == 0x80))
                    {
                        Local0 = Zero
                    }
                    Else
                    {
                        Local0--
                    }
                }

                If (Local0)
                {
                    Local0 = (Local1 & 0x1F)
                }
                Else
                {
                    If ((Arg0 == 0x07))
                    {
                        Arg3 = SMB0 /* \_SB_.PCI0.LPCB.EC0_.SMB0 */
                    }

                    If ((Arg0 == 0x47))
                    {
                        Arg3 = SMB0 /* \_SB_.PCI0.LPCB.EC0_.SMB0 */
                    }

                    If ((Arg0 == 0xC7))
                    {
                        Arg3 = SMB0 /* \_SB_.PCI0.LPCB.EC0_.SMB0 */
                    }

                    If ((Arg0 == 0x09))
                    {
                        Arg3 = B1B2(MW00, MW01) /* \_SB_.PCI0.LPCB.EC0_.SMW0 */
                    }

                    If ((Arg0 == 0x0B))
                    {
                        Local3 = BCNT /* \_SB_.PCI0.LPCB.EC0_.BCNT */
                        Local2 = 0x20
                        If ((Local3 > Local2))
                        {
                            Local3 = Local2
                        }

                        If ((Local3 < 0x09))
                        {
                            Local2 = RECB(0x04, 0x40) /* \_SB_.PCI0.LPCB.EC0_.FLD0 */
                        }
                        ElseIf ((Local3 < 0x11))
                        {
                            Local2 = RECB(0x04, 0x80) /* \_SB_.PCI0.LPCB.EC0_.FLD1 */
                        }
                        ElseIf ((Local3 < 0x19))
                        {
                            Local2 = RECB(0x04, 0xC0) /* \_SB_.PCI0.LPCB.EC0_.FLD2 */
                        }
                        Else
                        {
                            Local2 = RECB(0x04, 0x100) /* \_SB_.PCI0.LPCB.EC0_.FLD3 */
                        }

                        Local3++
                        Local4 = Buffer (Local3){}
                        Local3--
                        Local5 = Zero
                        Name (OEMS, Buffer (0x46){})
                        ToBuffer (Local2, OEMS) /* \_SB_.PCI0.LPCB.EC0_.SMRD.OEMS */
                        While ((Local3 > Local5))
                        {
                            GBFE (OEMS, Local5, RefOf (Local6))
                            PBFE (Local4, Local5, Local6)
                            Local5++
                        }

                        PBFE (Local4, Local5, Zero)
                        Arg3 = Local4
                    }
                }

                Release (MUT0)
                Return (Local0)
            }
            Else {
                Return(\_SB.PCI0.LPCB.EC0.XMRD(Arg0, Arg1, Arg2, Arg3))
            }
            }

            Method (SMWR, 4, NotSerialized)
            {
            If (_OSI("Darwin")) {
                If (!ECOK)
                {
                    Return (0xFF)
                }

                If ((Arg0 != 0x06))
                {
                    If ((Arg0 != 0x08))
                    {
                        If ((Arg0 != 0x0A))
                        {
                            If ((Arg0 != 0x46))
                            {
                                If ((Arg0 != 0xC6))
                                {
                                    Return (0x19)
                                }
                            }
                        }
                    }
                }

                Acquire (MUT0, 0xFFFF)
                Local0 = 0x04
                While ((Local0 > One))
                {
                    If ((Arg0 == 0x06))
                    {
                        SMB0 = Arg3
                    }

                    If ((Arg0 == 0x46))
                    {
                        SMB0 = Arg3
                    }

                    If ((Arg0 == 0xC6))
                    {
                        SMB0 = Arg3
                    }

                    If ((Arg0 == 0x08))
                    {
                        Local0 = 0
                        Local1 = 0
                        W16B(Local0, Local1, Arg3)
                        MW00 = Local0
                        MW01 = Local1
                    }

                    If ((Arg0 == 0x0A))
                    {
                        WECB (0x04, 0x100, Arg3)
                    }

                    SMST &= 0x40
                    SMCM = Arg2
                    SMAD = Arg1
                    SMPR = Arg0
                    Local3 = Zero
                    While (!Local1 = (SMST & 0xBF))
                    {
                        Sleep (0x02)
                        Local3++
                        If ((Local3 == 0x32))
                        {
                            SMST &= 0x40
                            SMCM = Arg2
                            SMAD = Arg1
                            SMPR = Arg0
                            Local3 = Zero
                        }
                    }

                    If ((Local1 == 0x80))
                    {
                        Local0 = Zero
                    }
                    Else
                    {
                        Local0--
                    }
                }

                If (Local0)
                {
                    Local0 = (Local1 & 0x1F)
                }

                Release (MUT0)
                Return (Local0)
            }
            Else {
                Return (\_SB.PCI0.LPCB.EC0.XMWR(Arg0, Arg1, Arg2, Arg3))
            }
            }
    }

    Scope(\_SB.BAT0) {
        Method (UPBI, 0, NotSerialized)
            {
            If (_OSI("Darwin")) {
                Local5 = B1B2(^^PCI0.LPCB.EC0.BFC0, ^^PCI0.LPCB.EC0.BFC1) /* \_SB_.PCI0.LPCB.EC0_.BFCC */
                If ((Local5 && !(Local5 & 0x8000)))
                {
                    Local5 >>= 0x05
                    Local5 <<= 0x05
                    PBIF [One] = Local5
                    PBIF [0x02] = Local5
                    Local2 = (Local5 / 0x64)
                    Local2 += One
                    If (((DTPY >= Zero) || (DTPY <= 0x03)))
                    {
                        If ((B1B2(^^PCI0.LPCB.EC0.BAD0, ^^PCI0.LPCB.EC0.BAD1) < 0x0C80))
                        {
                            Local4 = (Local2 * 0x0E)
                            PBIF [0x05] = (Local4 + 0x02)
                            Local4 = (Local2 * 0x09)
                            PBIF [0x06] = (Local4 + 0x02)
                            Local4 = (Local2 * 0x0C)
                        }
                        Else
                        {
                            Local4 = (Local2 * 0x0C)
                            PBIF [0x05] = (Local4 + 0x02)
                            Local4 = (Local2 * 0x07)
                            PBIF [0x06] = (Local4 + 0x02)
                            Local4 = (Local2 * 0x0A)
                        }

                        FABL = (Local4 + 0x02)
                    }
                    Else
                    {
                        Local4 = (Local2 * 0x0C)
                        PBIF [0x05] = (Local4 + 0x02)
                        Local4 = (Local2 * 0x07)
                        PBIF [0x06] = (Local4 + 0x02)
                        Local4 = (Local2 * 0x0A)
                        FABL = (Local4 + 0x02)
                    }
                }

                If (^^PCI0.LPCB.EC0.MBNH)
                {
                    Local0 = ^^PCI0.LPCB.EC0.BVLB /* \_SB_.PCI0.LPCB.EC0_.BVLB */
                    Local1 = ^^PCI0.LPCB.EC0.BVHB /* \_SB_.PCI0.LPCB.EC0_.BVHB */
                    Local1 <<= 0x08
                    Local0 |= Local1
                    PBIF [0x04] = Local0
                    PBIF [0x09] = "OANI$"
                    PBIF [0x0B] = "NiMH"
                }
                Else
                {
                    Local0 = ^^PCI0.LPCB.EC0.BVLB /* \_SB_.PCI0.LPCB.EC0_.BVLB */
                    Local1 = ^^PCI0.LPCB.EC0.BVHB /* \_SB_.PCI0.LPCB.EC0_.BVHB */
                    Local1 <<= 0x08
                    Local0 |= Local1
                    PBIF [0x04] = Local0
                    Sleep (0x32)
                    PBIF [0x0B] = "LION"
                }

                PBIF [0x09] = "Primary"
                UPUM ()
                PBIF [Zero] = One
            }
            Else {
                \_SB.BAT0.XPBI()
            }
            }
            
        Method (UPBS, 0, NotSerialized)
            {
            If (_OSI("Darwin")) {
                Local0 = B1B2(^^PCI0.LPCB.EC0.MCU0, ^^PCI0.LPCB.EC0.MCU1) /* \_SB_.PCI0.LPCB.EC0_.MCUR */
                If ((Local0 & 0x8000))
                {
                    If ((Local0 == 0xFFFF))
                    {
                        PBST [One] = 0xFFFFFFFF
                    }
                    Else
                    {
                        Local1 = ~Local0
                        Local1++
                        Local3 = (Local1 & 0xFFFF)
                        PBST [One] = Local3
                    }
                }
                Else
                {
                    PBST [One] = Local0
                }

                Local5 = B1B2(^^PCI0.LPCB.EC0.MBR0, ^^PCI0.LPCB.EC0.MBR1) /* \_SB_.PCI0.LPCB.EC0_.MBRM */
                If (!(Local5 & 0x8000))
                {
                    Local5 >>= 0x05
                    Local5 <<= 0x05
                    If ((Local5 != DerefOf (PBST [0x02])))
                    {
                        PBST [0x02] = Local5
                    }
                }

                If ((!^^PCI0.LPCB.EC0.SW2S && (^^PCI0.LPCB.EC0.BACR == One)))
                {
                    PBST [0x02] = FABL /* \_SB_.BAT0.FABL */
                }

                PBST [0x03] = B1B2(^^PCI0.LPCB.EC0.MBC0, ^^PCI0.LPCB.EC0.MBC1) /* \_SB_.PCI0.LPCB.EC0_.MBCV */
                PBST [Zero] = ^^PCI0.LPCB.EC0.MBST /* \_SB_.PCI0.LPCB.EC0_.MBST */
            }
            Else {
                \_SB.BAT0.XPBS()
            }
            }
    }
}