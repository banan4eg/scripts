script_name("AutoSchool Assist")
script_author("banan4eg")

----    Libraries    ----
require "lib.moonloader"
require "lib.sampfuncs"
-----------------------
local dlstatus = require('moonloader').download_status--
local vkeys = require "vkeys"
local rkeys = require 'rkeys'
local ev = require "lib.samp.events"
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local inicfg = require "inicfg"
imgui.ToggleButton = require 'imgui_addons'.ToggleButton
imgui.HotKey = require 'imgui_addons'.HotKey
local themes = import 'resource/imgui_themes.lua'
local fa = require 'faIcons'
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
----    Libraries    ----

update_state = false

local script_vers = 1
local script_vers_text = '1.01'

local update_url = 'https://raw.githubusercontent.com/banan4eg/scripts/master/ASAcfg.ini'
local update_path = getWorkingDirectory() .. '/config/ASAcfg.ini'

local script_url = 'https://raw.githubusercontent.com/banan4eg/scripts/master/AutoSchool.lua'
local script_path = thisScript().path

----     IniCFG      ----
if not doesDirectoryExist('moonloader/config') then
	createDirectory('moonloader/config')
end

local main_iniPath = getGameDirectory()..'\\moonloader\\config\\AutoSchoolCFG.ini'
if not doesFileExist(main_iniPath) then
	local f = io.open(main_iniPath, 'a')
		f:write('[config]\n')
            f:write('ASRang=0\n')
            f:write('Tag=\n')
            f:write('Gender=1\n')
            f:write('AutoScreen=false\n')
            f:write('LecF=false\n')
            f:write('TagF=false\n')
        f:write('[hotkeys]\n')
            f:write('MainMenu=[18,50]\n')
            f:write('Exam=[18,107]\n')
            f:write('Time=[18,106]\n')
            f:write('Hello=[17,49]\n')
            f:write('R=[18,111]\n')
            f:write('RN=[17,104]\n')
	f:close()
end
local main_ini = inicfg.load(nil, main_iniPath)
----     IniCFG      ----

----     Hotkeys     ----
local tLastKeys = {}

local ActiveMainMenu = {
	v = decodeJson(main_ini.hotkeys.MainMenu)
}
local ActiveExam = {
	v = decodeJson(main_ini.hotkeys.Exam)
}
local ActiveTime = {
	v = decodeJson(main_ini.hotkeys.Time)
}
local ActiveHello = {
	v = decodeJson(main_ini.hotkeys.Hello)
}
local ActiveR = {
	v = decodeJson(main_ini.hotkeys.R)
}
local ActiveRN = {
	v = decodeJson(main_ini.hotkeys.RN)
}
--[[
local Active = {
	v = decodeJson(main_ini.hotkeys.)
}
--]]
----     Hotkeys     ----

---- Local variables ----
local sw, sh = getScreenResolution()
-------------------------
local ASRang = imgui.ImInt(main_ini.config.ASRang)
RunCarExam = false
RunMotoExam = false
RunBigCarExam = false
CarExamResume = false
MotoExamResume = false
BigCarExamResume = false

date = os.date("%d.%m.%Y")

arr_rang = {u8'������', u8'�����������', u8'�����������', u8'��. ����������', u8'����������', u8'��������', u8'���. ���������', u8'��������'}
myrang = u8:decode(arr_rang[ASRang.v + 1])

---- Local variables ----

----   GUI Windows   ----
local Window = {
    Main = imgui.ImBool(false),
    Target = imgui.ImBool(false)
}

local Toggle = {
    AutoScreen = imgui.ImBool(main_ini.config.AutoScreen),
    LecF = imgui.ImBool(main_ini.config.LecF),
    TagF = imgui.ImBool(main_ini.config.TagF)
}

local Child = {
    Settings = false,
    Lekcii = false,
    Leader = false,
    InterviewM = false,
    Support = false,
    --------------
    Exam = false,
    Work = false
}

local SubChild = {
	
}

local Radio = {
    Gender = imgui.ImInt(main_ini.config.Gender)
}

local Input = {}
    Input['Tag'] = imgui.ImBuffer(''..main_ini.config.Tag, 256)
----   GUI Windows   ----

----    Main Block   ----
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

---- Variables after SAMPon ----
	local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nrpnick = sampGetPlayerNickname(id)
	Name, Surname = string.match(nrpnick, '(.+)_(.+)')
	rpnick = string.gsub(sampGetPlayerNickname(id), "_", " ")

	imgui.SwitchContext()
	themes.SwitchColorTheme(10)

    ----  Hotkeys  Func  ----
    bindMainMenu = rkeys.registerHotKey(ActiveMainMenu.v, true, MainMenuFunc)
    bindExam = rkeys.registerHotKey(ActiveExam.v, true, ExamFunc)
    bindTime = rkeys.registerHotKey(ActiveTime.v, true, TimeFunc)
    bindHello = rkeys.registerHotKey(ActiveHello.v, true, HelloFunc)
    bindR = rkeys.registerHotKey(ActiveR.v, true, RFunc)
    bindRN = rkeys.registerHotKey(ActiveRN.v, true, RNFunc)
    ----  Hotkeys  Func  ----

    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateini = inicfg.load(nil, update_path)
            if tonumber(updateini.script.version) > script_vers then
                sampAddChatMessage('{58ACFA}ASA{FFFFFF} � �������� {58ACFA}����� ������ {FFFFFF}�������', -1)
                sampAddChatMessage('{58ACFA}ASA{FFFFFF} � �������� ������ ����� � ����, �� ������� "{58ACFA}� �������{FFFFFF}"', -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)

    --repeat	wait(0)	until sampIsLocalPlayerSpawned()
    while true do wait(0)

 -- Dincamic variables --
    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if Radio['Gender'].v == 1 then Sex = '' SexL = '' else Sex = '�' SexL = '��' end
-- Dincamic variables --

if RunCarExam then
    local ax, ay, az = getCharCoordinates(1)
    local bx, by, bz = -2054, -171, 35 -- 1
    local ex, ey, ez = -2055, -199, 35 -- 2
    local qx, qy, qz = -2054, -243, 35 -- 3
    local wx, wy, wz = -2064, -246, 35 -- 4
    local ux, uy, uz = -2036, -260, 35 -- 5
    local px, py, pz = -2028, -219, 35 -- 7
    local ox, oy, oz = -2028, -250, 35 -- 6
    if math.sqrt( (ax - bx) ^ 5 + (ay - by) ^ 5 + (az - bz) ^ 5 ) < 10 and NextStepCar == 1 then -- 5 - ������ ������������
    wait(1000)
        sampSendChat("�������� �� ������� ����������� �� �������. ����� ������� ������ �������.")
        NextStepCar = 2
    elseif math.sqrt( (ax - ex) ^ 5 + (ay - ey) ^ 5 + (az - ez) ^ 5 ) < 10 and NextStepCar == 2 then -- 5 - ������ ������������
    wait(1000)
        sampSendChat("���������� �������� ������� �� �������� � ���������� ������ �������.")
        NextStepCar = 3
    elseif math.sqrt( (ax - qx) ^ 5 + (ay - qy) ^ 5 + (az - qz) ^ 5 ) < 10 and NextStepCar == 3 then -- 5 - ������ ������������\
    wait(1000)
        sampSendChat("������ ��������� ������ � ������������ �������.")
        NextStepCar = 4
    elseif math.sqrt( (ax - wx) ^ 5 + (ay - wy) ^ 5 + (az - wz) ^ 5 ) < 10 and NextStepCar == 4 then -- 5 - ������ ������������\
    wait(1000)
        sampSendChat("������ ������� �� �������� ������ ������� � ������� ��������.")
        NextStepCar = 5
    elseif math.sqrt( (ax - ux) ^ 5 + (ay - uy) ^ 5 + (az - uz) ^ 5 ) < 10 and NextStepCar == 5 then -- 5 - ������ ������������\
    wait(1000)
        sampSendChat("����������� � �������� � ������������ ����� ������.")
        NextStepCar = 6
    elseif math.sqrt( (ax - ox) ^ 5 + (ay - oy) ^ 5 + (az - oz) ^ 5 ) < 10 and NextStepCar == 6 then -- 5 - ������ ������������\
    wait(1000)
        sampSendChat("������ ��������� ���������� �� �����, ����� ����� ������� ���� ������������.")
        NextStepCar = 7
    elseif math.sqrt( (ax - px) ^ 5 + (ay - py) ^ 5 + (az - pz) ^ 5 ) < 10 and NextStepCar == 7 then -- 5 - ������ ������������\
    wait(1000)
    sampSendChat("�������, ������ ��������� ���������� �� ��������!")
    NextStepCar = 0
    RunCarExam = false
    CarExamResume = true
    end
end

if RunMotoExam then
    local ax, ay, az = getCharCoordinates(1)
    local bx, by, bz = -2112, -102, 35 -- 1
    local ex, ey, ez = -2110, -140, 35 -- 2
    local qx, qy, qz = -2118, -124, 35 -- 3
    local wx, wy, wz = -2144, -117, 35 -- 4
    local ux, uy, uz = -2145, -137, 35 -- 5
    local px, py, pz = -2125, -142, 35 -- 7
    local ox, oy, oz = -2135, -140, 35 -- 6
    local cx, cy, cz = -2146, -149, 35 -- 8
    local sx, sy, sz = -2121, -151, 35 -- 9
    local vx, vy, vz = -2104, -108, 35 -- 10
    if math.sqrt( (ax - bx) ^ 5 + (ay - by) ^ 5 + (az - bz) ^ 5 ) < 10 and NextStepMoto == 1 then -- 5 - ������ ������������
    wait(1000)
        sampSendChat('���������� �������� ������� �� �������� � ���������� ������ �������.')
        NextStepMoto = 2
    elseif math.sqrt( (ax - ex) ^ 5 + (ay - ey) ^ 5 + (az - ez) ^ 5 ) < 10 and NextStepMoto == 2 then -- 5 - ������ ������������
    wait(1000)
        sampSendChat('������ �� ��������, ���������� � ������� ��������.')
        NextStepMoto = 3
    elseif math.sqrt( (ax - qx) ^ 5 + (ay - qy) ^ 5 + (az - qz) ^ 5 ) < 10 and NextStepMoto == 3 then -- 5 - ������ ������������\
    wait(1000)
        sampSendChat('������ ��������� ���������� �� ��������.')
        NextStepMoto = 4
    elseif math.sqrt( (ax - wx) ^ 5 + (ay - wy) ^ 5 + (az - wz) ^ 5 ) < 10 and NextStepMoto == 4 then -- 5 - ������ ������������\
    wait(1000)
        sampSendChat('������ ��������, �������� ��������� ������ ������')
        NextStepMoto = 5
    elseif math.sqrt( (ax - ux) ^ 5 + (ay - uy) ^ 5 + (az - uz) ^ 5 ) < 10 and NextStepMoto == 5 then -- 5 - ������ ������������\
    wait(1000)
        sampSendChat('� ������ ����������� �������� � ������������ �������.')
        NextStepMoto = 6
    elseif math.sqrt( (ax - ox) ^ 2 + (ay - oy) ^ 2 + (az - oz) ^ 2 ) < 5 and NextStepMoto == 6 then -- 5 - ������ ������������\
    wait(1000)
        sampSendChat('����������� ��������, ������� �� ����������� ��������.')
        NextStepMoto = 7
    elseif math.sqrt( (ax - px) ^ 3 + (ay - py) ^ 3 + (az - pz) ^ 3 ) < 6 and NextStepMoto == 7 then -- 5 - ������ ������������\
    wait(1000)
        sampSendChat('����������� �����������, ������� ����� ��������.')
        NextStepMoto = 8
    elseif math.sqrt( (ax - cx) ^ 5 + (ay - cy) ^ 5 + (az - cz) ^ 5 ) < 10 and NextStepMoto == 8 then -- 5 - ������ ������������\
    wait(1000)
        sampSendChat('����������� ������������� ����������')
        NextStepMoto = 9
    elseif math.sqrt( (ax - sx) ^ 5 + (ay - sy) ^ 5 + (az - sz) ^ 5 ) < 10 and NextStepMoto == 9 then -- 5 - ������ ������������\
    wait(1000)
        sampSendChat('��� ����� �������� ������ ������� �� ���������� ��������.')
        NextStepMoto = 10
    elseif math.sqrt( (ax - vx) ^ 5 + (ay - vy) ^ 5 + (az - vz) ^ 5 ) < 10 and NextStepMoto == 10 then -- 5 - ������ ������������\
    wait(1000)
        sampSendChat('������ ����������� �������� � ��� �����, ��� ��� �����.')
    NextStepMoto = 0
    RunMotoExam = false
    MotoExamResume = true
    end
end

if RunBigCarExam then
    local ax, ay, az = getCharCoordinates(1)  
    local bx, by, bz = -2130, -85, 35 -- 1
    --local ex, ey, ez = -2087, -68, 35 -- 2
    if math.sqrt( (ax - bx) ^ 5 + (ay - by) ^ 5 + (az - bz) ^ 5 ) < 10 and NextStepBigCar == 1 then -- 5 - ������ ������������
    wait(1000)
        sampSendChat('��������� ������, ����� ���� �������� ���� ������ ������������� ������')
        wait(2000)
        sampSendChat('������������� �� ��������� ������ ������.')
        --NextStepBigCar = 2
    --elseif math.sqrt( (ax - ex) ^ 5 + (ay - ey) ^ 5 + (az - ez) ^ 5 ) < 10 and NextStepBigCar == 2 then -- 5 - ������ ������������
    --wait(1000)
    NextStepBigCar = 0
    RunBigCarExam = false
    BigCarExamResume = true
    end
end

    end
end
----    Main Block   ----

function MainMenuFunc()
    if not Window['Target'].v then
        local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
            if valid and doesCharExist(ped) then
                targ_tr, tid = sampGetPlayerIdByCharHandle(ped)
                    if targ_tr then
                        targ_bl = addBlipForChar(ped)
                        Window['Target'].v = true
                        imgui.Process = Window['Target'].v
                    end
            else
                Window['Main'].v = not Window['Main'].v
                imgui.Process = Window['Main'].v 
            end
    elseif Window['Target'].v then
        Window['Target'].v = false
        removeBlip(targ_bl)
    end
end

function ExamFunc()
    sampSendChat('/exam')
end

function TimeFunc()
    sampSendChat('/time')
end

function HelloFunc()
    sampSendChat('������������, � '..myrang..', '..rpnick..', ��� ���� ���� �������?')
end

function RFunc()
    sampSetChatInputEnabled(true)
    if Toggle['TagF'].v then
    sampSetChatInputText('/f '..u8:decode(Input['Tag'].v)..' ')
    else
    sampSetChatInputText('/f ')
    end
end

function RNFunc()
    sampSetChatInputEnabled(true)
    sampSetChatInputText('/fn ') 
end

function TimeScreen()
    lua_thread.create(function()
        sampSendChat('/time')
        wait(1000)
        makeScreen()
    end)
end

function ExamEnd(Result)
    lua_thread.create(function()
        repeat wait(0) until sampIsDialogActive() and sampGetCurrentDialogId() == 577
        sampSetCurrentDialogListItem(Result)
        setVirtualKeyDown(0x0D, true)
        wait(50)
        setVirtualKeyDown(0x0D, false)
    end)
end

----   ImGui Block   ----
function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
        font_config.MergeMode = true
        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
    end
end
-------------------------
function imgui.OnDrawFrame()
    if not Window['Main'].v and not Window['Target'].v then
		imgui.Process = false
	end

    if Window['Main'].v then
        --local targNick = sampGetPlayerNickname(hid)
		imgui.SetNextWindowSize(imgui.ImVec2(371, 310), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2+300, sh/2+120), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin(u8"AutoSchool Assist##1", Window['Main'], imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        local Xbm, Ybm = 79, 25 --X 120
        --imgui.SetCursorPosX(imgui.ImVec2(10, 55))
        imgui.BeginChild('Main', imgui.ImVec2(94, 275), true)
            if imgui.Button(u8'������', imgui.ImVec2(Xbm, Ybm)) then Child['Lekcii'] = not Child['Lekcii'] Child['Settings'] = false Child['Leader'] = false Child['InterviewM'] = false Child['Support'] = false end
            if imgui.Button(u8'���. �������', imgui.ImVec2(Xbm, Ybm)) then Child['Leader'] = not Child['Leader'] Child['Lekcii'] = false Child['Settings'] = false Child['InterviewM'] = false Child['Support'] = false end
            if imgui.Button(u8'���������', imgui.ImVec2(Xbm, Ybm)) then Child['Settings'] = not Child['Settings'] Child['Lekcii'] = false Child['Leader'] = false Child['InterviewM'] = false Child['Support'] = false end
            if imgui.Button(u8'�������-���', imgui.ImVec2(Xbm, Ybm)) then Child['InterviewM'] = not Child['InterviewM'] Child['Lekcii'] = false Child['Leader'] = false Child['Settings'] = false Child['Support'] = false end
            imgui.SetCursorPosY(242)
            if imgui.Button(u8'� �������', imgui.ImVec2(Xbm, Ybm)) then Child['Support'] = not Child['Support'] Child['Lekcii'] = false Child['Leader'] = false Child['Settings'] = false Child['InterviewM'] = false end
        imgui.EndChild()
        imgui.SameLine()

            imgui.SetCursorPosX(110)
            imgui.BeginChild('Settings', imgui.ImVec2(255,275), true)
            if Child['Settings'] then
                local XposEl, XposBinds = 120, 145
                imgui.SetCursorPosY(10)
                imgui.Text(u8'���� ���������:') imgui.SameLine()
                imgui.PushItemWidth(125) imgui.SetCursorPos(imgui.ImVec2(XposEl,9))
                if imgui.Combo('##ASRang', ASRang, arr_rang, #arr_rang)  then
                    main_ini.config.ASRang = ASRang.v
                    inicfg.save(main_ini, main_iniPath)
                end
                imgui.Text(u8'��� � �����:') imgui.SameLine()
                if imgui.ToggleButton(u8'tagF', Toggle['TagF']) then main_ini.config.TagF = Toggle['TagF'].v inicfg.save(main_ini, main_iniPath) end 
                imgui.SameLine() imgui.SetCursorPosX(XposEl)
                if imgui.InputText('##InputTag', Input['Tag']) then
                    main_ini.config.Tag = Input['Tag'].v 
                    inicfg.save(main_ini, main_iniPath)
                end
                imgui.Text(u8'��� ���:') imgui.SameLine() imgui.SetCursorPosX(130)
                if imgui.RadioButton(u8'���', Radio['Gender'], 1) then main_ini.config.Gender = Radio['Gender'].v inicfg.save(main_ini, main_iniPath) end
                imgui.SameLine()
                if imgui.RadioButton(u8'���', Radio['Gender'], 2) then main_ini.config.Gender = Radio['Gender'].v inicfg.save(main_ini, main_iniPath) end
                imgui.Text(u8'����-�����:') imgui.SameLine()
                if imgui.ToggleButton('', Toggle['AutoScreen']) then main_ini.config.AutoScreen = Toggle['AutoScreen'].v inicfg.save(main_ini, main_iniPath) end
                imgui.SameLine()
                imgui.TextQuestion(u8'��� ���������� ����-������, ���������:\n����� �������� ���������, ������� ��������, ��������� ����, ����������� ������.')
                imgui.Separator() imgui.SetCursorPosX(70) imgui.Text(u8"��������� ������") imgui.Separator()
                imgui.Text(u8"���������� ����")
                imgui.SameLine() imgui.SetCursorPosX(XposBinds)
                if imgui.HotKey("##1", ActiveMainMenu, tLastKeys, 100) then
                    rkeys.changeHotKey(bindMainMenu, ActiveMainMenu.v)
                    --sampAddChatMessage("�������! ������ ��������: {F4A460}" .. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. "{ffffff} | �����: {F4A460}" .. table.concat(rkeys.getKeysName(ActiveMainMenu.v), " + "), -1)
                    --sampAddChatMessage("�������� ��������: {F4A460}" .. encodeJson(ActiveMainMenu.v), -1)
                    main_ini.hotkeys.MainMenu = encodeJson(ActiveMainMenu.v)
                    inicfg.save(main_ini, main_iniPath)
                end
                imgui.Text(u8"/exam")
                imgui.SameLine() imgui.SetCursorPosX(XposBinds)
                if imgui.HotKey("##2", ActiveExam, tLastKeys, 100) then
                    rkeys.changeHotKey(bindExam, ActiveExam.v)
                    main_ini.hotkeys.Exam = encodeJson(ActiveExam.v)
                    inicfg.save(main_ini, main_iniPath)
                end
                imgui.Text(u8"/time")
                imgui.SameLine() imgui.SetCursorPosX(XposBinds)
                if imgui.HotKey("##3", ActiveTime, tLastKeys, 100) then
                    rkeys.changeHotKey(bindTime, ActiveTime.v)
                    main_ini.hotkeys.Time = encodeJson(ActiveTime.v)
                    inicfg.save(main_ini, main_iniPath)
                end
                imgui.Text(u8"�����������")
                imgui.SameLine() imgui.SetCursorPosX(XposBinds)
                if imgui.HotKey("##4", ActiveHello, tLastKeys, 100) then
                    rkeys.changeHotKey(bindHello, ActiveHello.v)
                    main_ini.hotkeys.Hello = encodeJson(ActiveHello.v)
                    inicfg.save(main_ini, main_iniPath)
                end
                imgui.Text(u8"�����")
                imgui.SameLine() imgui.SetCursorPosX(XposBinds)
                if imgui.HotKey("##5", ActiveR, tLastKeys, 100) then
                    rkeys.changeHotKey(bindR, ActiveR.v)
                    main_ini.hotkeys.R = encodeJson(ActiveR.v)
                    inicfg.save(main_ini, main_iniPath)
                end
                imgui.Text(u8"��� �����")
                imgui.SameLine() imgui.SetCursorPosX(XposBinds)
                if imgui.HotKey("##6", ActiveRN, tLastKeys, 100) then
                    rkeys.changeHotKey(bindRN, ActiveRN.v)
                    main_ini.hotkeys.RN = encodeJson(ActiveRN.v)
                    inicfg.save(main_ini, main_iniPath)
                end
            elseif Child['Lekcii'] then
                local Xbl, Ybl = 240, 25
                if imgui.Button(u8'��������� � ������������ ������', imgui.ImVec2(Xbl, Ybl)) then vehicleLC() end
                if imgui.Button(u8'������ � ������������', imgui.ImVec2(Xbl, Ybl)) then EticetSub() end
                if imgui.Button(u8'������� ������������� �����', imgui.ImVec2(Xbl, Ybl)) then RulesUseR() end
                if imgui.Button(u8'�������� ������� � ����������� ��', imgui.ImVec2(Xbl, Ybl)) then GeneralRules() end
                if imgui.Button(u8'������� ������������� �����', imgui.ImVec2(Xbl, Ybl)) then RulesUseDesk() end imgui.Text('')
                if imgui.ToggleButton(u8'������ � /f', Toggle['LecF']) then main_ini.config.LecF = Toggle['LecF'].v inicfg.save(main_ini, main_iniPath) end
                imgui.SameLine()
                imgui.TextQuestion(u8'���� ��������, ����� ������ ������ � �����\n���� ���������, ����� ������ ������ � ���')
            elseif Child['Leader'] then
                local Xbl2, Ybl2 = 240, 25
                if imgui.Button(u8'���������', imgui.ImVec2(Xbl2, Ybl2)) then rangup(2) end
                if imgui.Button(u8'������ ����', imgui.ImVec2(Xbl2, Ybl2)) then giveskin(2) end
                if imgui.Button(u8'�������', imgui.ImVec2(Xbl2, Ybl2)) then givewarn(2) end
                if imgui.Button(u8'������� � ��������', imgui.ImVec2(Xbl2, Ybl2)) then givewarnoff(2) end
                if imgui.Button(u8'������ ��������', imgui.ImVec2(Xbl2, Ybl2)) then takeoffwarn(2) end
                if imgui.Button(u8'����������', imgui.ImVec2(Xbl2, Ybl2)) then uninvite(2) end
                if imgui.Button(u8'���������� � ��������', imgui.ImVec2(Xbl2, Ybl2)) then uninviteoff(2) end
                if imgui.Button(u8'��������� � ��', imgui.ImVec2(Xbl2, Ybl2)) then gobl(2) end
                if imgui.Button(u8'��������� � �� � ��������', imgui.ImVec2(Xbl2, Ybl2)) then gobloff(2) end
                if imgui.Button(u8'��������� �� ��', imgui.ImVec2(Xbl2, Ybl2)) then backbl(2) end
                if imgui.Button(u8'������� �������� (/invite)', imgui.ImVec2(Xbl2, Ybl2)) then inviteFunc(2) end
            elseif Child['InterviewM'] then
                local Xbi2, Ybi2 = 240, 23
                local Xbi3, Ybi3 = 116, 23
                if imgui.Button(u8'������ (1)', imgui.ImVec2(Xbi2-165, Ybi2+5)) then 
                    lua_thread.create(function()
                        sampSendChat("������������, �� �� �������������?")
                        wait(200)
                        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ����� ������ ������� - {58ACFA}1{FFFFFF}. ������ - {58ACFA}2{FFFFFF}.', -1)
                        repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
                        if isKeyJustPressed(0x31) then
                            sampSendChat('������, �������� ��� �������, �������� � ����������� �����.')
                            wait(2000)
                            sampSendChat('/n �������� ������� - /pass '..myid..' , ���. ����� - /med '..myid..', �������� - /lic '..myid..'.')
                        elseif isKeyJustPressed(0x32) then
                        end
                    end)
                end imgui.SameLine()
                if imgui.Button(u8'������ ��? (4)', imgui.ImVec2(Xbi2-145, Ybi2+5)) then 
                    lua_thread.create(function()
                        sampSendChat('������, �������� ��� ����� ������� ��������')
                        wait(2000)
                        sampSendChat('� ������ �� ������ �������� ������ � ���?')
                    end)
                end imgui.SameLine()
                if imgui.Button(u8'�������', imgui.ImVec2(Xbi2-185, Ybi2+5)) then 
                    inviteFunc(1)
                end
                imgui.Separator()
                imgui.TextRGB('    �� ������� (2)') imgui.SameLine() imgui.TextRGB('�������� (3)      ', 3)
                --imgui.Separator()
                    if imgui.Button(u8'��� ��� �������?', imgui.ImVec2(Xbi3, Ybi3)) then 
                        sampSendChat('������, ��� � ���� ��� �������?')
                    end imgui.SameLine()
                    if imgui.Button(u8'������ (IC)', imgui.ImVec2(Xbi3, Ybi3)) then 
                        sampSendChat('������.')
                    end
                    if imgui.Button(u8'��� ����� ��?', imgui.ImVec2(Xbi3, Ybi3)) then 
                        sampSendChat('������, ��� ����� ��?')
                    end imgui.SameLine()
                    if imgui.Button(u8'�������� (OOC)', imgui.ImVec2(Xbi3, Ybi3)) then 
                        sampSendChat('/n ���������.')
                    end
                    if imgui.Button(u8'��� ����� ��?', imgui.ImVec2(Xbi3, Ybi3)) then 
                        sampSendChat('������, ��� ����� ��?')
                    end imgui.SameLine()
                    if imgui.Button(u8'�������� (IC)', imgui.ImVec2(Xbi3, Ybi3)) then 
                        sampSendChat('���������.')
                    end
                imgui.Separator()
                    imgui.TextRGB('����� �� �������') imgui.SameLine()
                    imgui.SetCursorPosX(155)
                    imgui.Text(u8'�������� '..fa.ICON_LONG_ARROW_RIGHT) imgui.SameLine()
                    imgui.TextQuestion(u8'���� ���������������. (( ����������������� 15+ ))\n��������� � ���������� 3 ���� (( ����� 3 LvL ))\n����� ���������� ����������� ������.')
                    if imgui.Button(u8'������������ �����������������', imgui.ImVec2(Xbi2, Ybi2)) then 
                        lua_thread.create(function()
                            sampSendChat('��������, �� �� �����������������. ��������.')
                            wait(1500)
                            sampSendChat('/n ���������� 15+ �����������������.')
                        end)
                    end
                    if imgui.Button(u8'����� ���', imgui.ImVec2(Xbi2, Ybi2)) then 
                        lua_thread.create(function()
                            sampSendChat('� ��� �������� � ��������, �� �� �������.')
                            wait(2000)
                            sampSendChat('/n ������� /mn - ����� ����� ����.')
                        end)
                    end
                    if imgui.Button(u8'��� 18 ���', imgui.ImVec2(Xbi2, Ybi2)) then 
                        sampSendChat('��� ��� 18 ���, �� �� �������.')
                    end
                    if imgui.Button(u8'������� �����', imgui.ImVec2(Xbi2, Ybi2)) then 
                        sampSendChat('��������, �� ��� �� ���������.')
                    end
            elseif Child['Support'] then
                imgui.TextRGB('����� ������� - {FFFF00}Banana Blackstone', 2)
                imgui.TextRGB('������� �� ������ - {FF8000}Lance Connors', 2)
                imgui.Text('')
                imgui.TextRGB('������ {01DF01}Emerald', 2)

                imgui.SetCursorPos(imgui.ImVec2(58, 160))
                if imgui.Button(u8'�������� ������', imgui.ImVec2(140, 25)) then
                    if update_state then
                        downloadUrlToFile(script_url, script_path, function(id, status)
                            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                                sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������ {58ACFA}������� {FFFFFF}��������', -1)
                                thisScript():reload()
                            end
                        end)
                    else
                        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � � ��� {58ACFA}��������� ������{FFFFFF} �������', -1)
                    end
                end imgui.SetCursorPosX(58)
                if imgui.Button(u8'��������� ���������', imgui.ImVec2(140, 25)) then latest_update() end imgui.SetCursorPosY(250)
                imgui.TextRGB('������ ������� - '..updateini.script.version_text, 3)
            elseif not Child['Settings'] and not Child['Lekcii'] and not Child['Leader'] and not Child['InterviewM'] and not Child['Support'] then
                
            end
        imgui.EndChild()



        imgui.End()
    end

    if Window['Target'].v then
        local targNick = sampGetPlayerNickname(tid)
        targrpnick = string.gsub(sampGetPlayerNickname(tid), "_", " ")
		imgui.SetNextWindowSize(imgui.ImVec2(271, 339), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2+300, sh/2+110), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin(u8'�������� � '..targNick..'['..tid..']##2', Window['Target'], imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        local Xbm, Ybm = 123, 25 --X 120
        imgui.SetCursorPosY(25)
        if imgui.Button(u8'�������', imgui.ImVec2(Xbm, Ybm)) then Child['Exam'] = not Child['Exam'] Child['Work'] = false end
        imgui.SameLine()
        if imgui.Button(u8'���������', imgui.ImVec2(Xbm, Ybm)) then Child['Work'] = not Child['Work'] Child['Exam'] = false end

            imgui.SetCursorPosY(55)
            imgui.BeginChild('Settings2', imgui.ImVec2(255,275), true)
            if Child['Exam'] then
                imgui.Text(u8'�������� ��������:') imgui.Separator()
                local Xsb, Ysb = 240, 25
                if imgui.Button(u8'�������� ���������', imgui.ImVec2(Xsb,Ysb)) then
                    carExam()
                end
                if imgui.Button(u8'��������� ���������', imgui.ImVec2(Xsb,Ysb)) then
                    airExam()
                end
                if imgui.Button(u8'�������������', imgui.ImVec2(Xsb,Ysb)) then
                    motoExam()
                end
                if imgui.Button(u8'�������� �������', imgui.ImVec2(Xsb,Ysb)) then
                    bigcarExam()
                end
                imgui.Text('') imgui.Separator()
                if imgui.Button(u8'�������� �� ������', imgui.ImVec2(Xsb,Ysb)) then
                    SellLic(2)
                end
                if imgui.Button(u8'�������� �� ������ ���������', imgui.ImVec2(Xsb,Ysb)) then
                    SellLic(1)
                end
                if imgui.Button(u8'���������', imgui.ImVec2(Xsb,Ysb)) then
                    sellinsurance()
                end
            elseif Child['Work'] then
                local Xbl2, Ybl2 = 240, 25
                if imgui.Button(u8'���������', imgui.ImVec2(Xbl2, Ybl2)) then rangup(1) end
                if imgui.Button(u8'������ ����', imgui.ImVec2(Xbl2, Ybl2)) then giveskin(1) end
                if imgui.Button(u8'�������', imgui.ImVec2(Xbl2, Ybl2)) then givewarn(1) end
                if imgui.Button(u8'������ ��������', imgui.ImVec2(Xbl2, Ybl2)) then takeoffwarn(1) end
                if imgui.Button(u8'����������', imgui.ImVec2(Xbl2, Ybl2)) then uninvite(1) end
                if imgui.Button(u8'��������� � ��', imgui.ImVec2(Xbl2, Ybl2)) then gobl(1) end
                if imgui.Button(u8'��������� �� ��', imgui.ImVec2(Xbl2, Ybl2)) then backbl(1) end
                if imgui.Button(u8'������� �������� (/invite)', imgui.ImVec2(Xbl2, Ybl2)) then inviteFunc(3) end
            elseif not Child['Exam'] and not Child['Work'] then
                Child['Exam'] = true
            end
            imgui.EndChild()
        imgui.End()
    elseif not Window['Target'].v then
        removeBlip(targ_bl)
    end

end

--sampAddChatMessage('', -1)

function carExam()
    lua_thread.create(function()
        sampSendChat('������������, � ��������� ��������� '..rpnick..' � � ���� ��������� � ��� �������.')
        wait(2100)
        sampSendChat('���������� ��� �������.')
        wait(2100)
        sampSendChat('/n ������� �������: /pass '..myid)
        wait(200)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��������: {58ACFA}18+ ���{FFFFFF}.', -1) wait(1)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��� ����������� ������� - {58ACFA}1{FFFFFF}. ���� �� �������, �� ������� - {58ACFA}2{FFFFFF}. ������ - {58ACFA}3{FFFFFF}.', -1)
        repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
        if isKeyJustPressed(0x31) then
            sampSendChat('/me ������'..Sex..' ����� � ����� �� ������� ������')
            wait(2100)
            sampSendChat('/me ������'..Sex..' ��� � ������� �������������, ����� ���� �������'..Sex..' ����� ���')
            wait(2100)
            sampSendChat('�������� �� ���� ��� ����� ������������ ����� ��������.')
            wait(2100)
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' �����'..Sex..' ��������� ������� � �������� �'..tid..' '..targrpnick..' || ���������: �������� ���������')
            else
                sampSendChat('/f �����'..Sex..' ��������� ������� � �������� �'..tid..' '..targrpnick..' || ���������: �������� ���������')
            end
            wait(200)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��� ����������� ������� - {58ACFA}1{FFFFFF}. ������ - {58ACFA}2{FFFFFF}.', -1)
                repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
                if isKeyJustPressed(0x31) then
                    sampSendChat('�������������� �� ����� �������� � �������� ���� ���������� ��������.')
                    wait(2100)
                    sampSendChat('��� ������ ����������� ������ ������������.')
                    wait(2100)
                    sampSendChat('/n /me ����������(�) ������ ������������')
                    wait(2100)
                    sampSendChat('/me ����������'..Sex..' ������ ������������')
                    wait(2100)
                    sampSendChat('�������� ���������, ��������� ���� � ���������� � ����� "�����".')
                    wait(2100)
                    sampSendChat('/n ������� ��������� ����� ����� �� ������� [Ctrl], �������� ���� [Alt].')
                    RunCarExam = true
                    NextStepCar = 1
                    while not CarExamResume do
                        wait(0)
                        if CarExamResume then
                            wait(1500)
                            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ����� ���� ��� ��������������, �������:', -1)
                            wait(1)
                            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ���� - {58ACFA}1{FFFFFF}, �� ���� - {58ACFA}2{FFFFFF}, ������ - {58ACFA}3{FFFFFF}.', -1)
                            repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
                            if isKeyJustPressed(0x31) then
                                sampSendChat('/me ���������'..Sex..' ����, ����� ���� ������'..Sex..' ������ � �����'..Sex..' ��������� ��')
                                wait(2100)
                                sampSendChat('/me ������'..Sex..' ��� � ������� �������')
                                wait(2100)
                                sampSendChat('/me ������'..Sex..' ������ ����� ������������ �������������, ����� ���� �������'..Sex..' �������')
                                wait(2100)
                                sampSendChat('/me ����� ���������� ����������, ��������� ������'..Sex..' �� � ������'..Sex..' ����')
                                wait(2100)
                                if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                                    sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������'..Sex..' ������� � �������� �'..tid..' '..targrpnick..' || ���������: �������� ��������� || ���������: �������.')
                                else
                                    sampSendChat('/f ��������'..Sex..' ������� � �������� �'..tid..' '..targrpnick..' || ���������: �������� ��������� || ���������: �������.')
                                end
                                ExamEnd(1)
                                wait(2100)
                                sampSendChat('/exam')
                                if Toggle['AutoScreen'].v then TimeScreen() end
                                CarExamResume = false
                                congr()
                            elseif isKeyJustPressed(0x32) then
                                sampSendChat('�� ��������� ������� ����� ������, ������������� �� ���������.')
                                wait(2100)
                                if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                                    sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������'..Sex..' ������� � �������� �'..tid..' '..targrpnick..' || ���������: �������� ��������� || ���������: �� ������.')
                                else
                                    sampSendChat('/f ��������'..Sex..' ������� � �������� �'..tid..' '..targrpnick..' || ���������: �������� ��������� || ���������: �� ������.')
                                end
                                ExamEnd(2)
                                wait(2100)
                                sampSendChat('/exam')
                                CarExamResume = false
                            elseif isKeyJustPressed(0x33) then
                                thisScript():reload()
                            end
                        end
                    end
                elseif isKeyJustPressed(0x32) then
                    thisScript():reload()
                end
        elseif isKeyJustPressed(0x32) then
            sampSendChat('� ��� �������� � �����������, � �� ���� ������� � ��� �������.')
            ExamEnd(2)
            wait(2000)
            sampSendChat('/exam')
        elseif isKeyJustPressed(0x33) then
            thisScript():reload()
        end
    end)
end

function airExam()
    lua_thread.create(function()
        sampSendChat('������������, � ��������� ���������, '..rpnick..' � � ���� ��������� � ��� �������.')
        wait(2100)
        sampSendChat('���������� ��� ������� � ����������� �����.')
        wait(2100)
        sampSendChat('/n ������� �������: /pass '..myid..', ���. �����: /med '..myid)
        wait(200)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��������: {58ACFA}18+ ���{FFFFFF} � ��������� ���. ������ � {58ACFA}2 LvL{FFFFFF}', -1) wait(1)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��� ����������� ������� - {58ACFA}1{FFFFFF}. ���� �� �������, �� ������� - {58ACFA}2{FFFFFF}. ������ - {58ACFA}3{FFFFFF}.', -1)
        repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
        if isKeyJustPressed(0x31) then
            sampSendChat('/me ������'..Sex..' ����� � ����� �� ������� ����')
            wait(2100)
            sampSendChat('/me ������'..Sex..' ��� � ������� �������������, ����� ���� �������'..Sex..' ���')
            wait(2100)
            sampSendChat('�������� �� ���� ��� ����� ������������ ����� ��������.')
            wait(2100)
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' �����'..Sex..' ��������� ������� � �������� �'..tid..' '..targrpnick..' || ���������: ��������� ���������')
            else
                sampSendChat('/f �����'..Sex..' ��������� ������� � �������� �'..tid..' '..targrpnick..' || ���������: ��������� ���������') 
            end
            wait(200)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��� ����������� ������� - {58ACFA}1{FFFFFF}. ������ - {58ACFA}2{FFFFFF}.', -1)
                repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
                if isKeyJustPressed(0x31) then
                    sampSendChat('�������� �� ����� ������, ����� ���� ����� ���� ��������.')
                    wait(2100)
                    sampSendChat('��� ������ �������� ��������, ����������� ������ ������������.')
                    wait(2100)
                    sampSendChat('/n /me �����(�) �������� � ����������(�) ������ ������������')
                    wait(2100)
                    sampSendChat('/me �����'..Sex..' �������� � ����������'..Sex..' ������ ������������')
                    wait(2100)
                    sampSendChat('������ �������� ��������� � ��������, ������ ���� �� ���������� ���������.')
                    wait(2100)
                    sampSendChat('����� ����, ��� �������� ���� - ������������� � �� �����, ������ ����� �������.')
                    wait(1500)
                    sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ����� ���� ��� ������������, �������:', -1)
                    wait(1)
                    sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ���� - {58ACFA}1{FFFFFF}, �� ���� - {58ACFA}2{FFFFFF}, ������ - {58ACFA}3{FFFFFF}.', -1)
                    repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
                    if isKeyJustPressed(0x31) then
                        sampSendChat('/me ���������'..Sex..' ����, ����� ���� ������'..Sex..' ������ � �����'..Sex..' ��������� ��')
                        wait(2100)
                        sampSendChat('/me ������'..Sex..' ��� � ������� �������')
                        wait(2100)
                        sampSendChat('/me ������'..Sex..' ������ ����� ������������ �������������, ����� ���� �������'..Sex..' �������')
                        wait(2100)
                        sampSendChat('/me ����� ���������� ����������, ��������� ������'..Sex..' �� � ������'..Sex..' ����')
                        wait(2100)
                        if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                            sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������'..Sex..' ������� � �������� �'..tid..' '..targrpnick..' || ���������: ��������� ��������� || ���������: �������.')
                        else
                            sampSendChat('/f ��������'..Sex..' ������� � �������� �'..tid..' '..targrpnick..' || ���������: ��������� ��������� || ���������: �������.') 
                        end
                        ExamEnd(1)
                        wait(2100)
                        sampSendChat('/exam')
                        if Toggle['AutoScreen'].v then TimeScreen() end
                        congr()
                    elseif isKeyJustPressed(0x32) then
                        sampSendChat('�� ��������� ������� ����� ������, ������������� �� ���������.')
                        wait(2100)
                        if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                            sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������'..Sex..' ������� � �������� �'..tid..' '..targrpnick..' || ���������: ��������� ��������� || ���������: �� ������.')
                        else
                            sampSendChat('/f ��������'..Sex..' ������� � �������� �'..tid..' '..targrpnick..' || ���������: ��������� ��������� || ���������: �� ������.') 
                        end
                        ExamEnd(2)
                        wait(2100)
                        sampSendChat('/exam')
                    elseif isKeyJustPressed(0x33) then
                        thisScript():reload()
                    end
                elseif isKeyJustPressed(0x32) then
                    thisScript():reload()
                end
        elseif isKeyJustPressed(0x32) then
            sampSendChat('� ��� �������� � �����������, � �� ���� ������� � ��� �������.')
            ExamEnd(2)
            wait(2000)
            sampSendChat('/exam')
        elseif isKeyJustPressed(0x33) then
            thisScript():reload()
        end
    end)
end

function motoExam()
    lua_thread.create(function()
        sampSendChat('������������, � ��������� ��������� '..rpnick..' � � ���� ��������� �������.')
        wait(2100)
        sampSendChat('���������� ��� ������� � ���.�����')
        wait(2100)
        sampSendChat('/n ������� �������: /pass '..myid..', ���. �����: /med '..myid)
        wait(200)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��������: {58ACFA}18+ ���{FFFFFF} � ��������� ���. ������ � {58ACFA}2 LvL{FFFFFF}', -1) wait(1)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��� ����������� ������� - {58ACFA}1{FFFFFF}. ���� �� �������, �� ������� - {58ACFA}2{FFFFFF}. ������ - {58ACFA}3{FFFFFF}.', -1)
        repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
        if isKeyJustPressed(0x31) then
            sampSendChat('/me ������'..Sex..' ����� � ����� �� ������� ����')
            wait(2100)
            sampSendChat('/me ������'..Sex..' ��� � ������� �������������, ����� ���� �������'..Sex..' ���')
            wait(2100)
            sampSendChat('�������� �� ���� ��� ����� ������������ ����� ��������.')
            wait(2100)
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' �����'..Sex..' ��������� ������� � �������� �'..tid..' '..targrpnick..' | ���������: �������������')
            else
                sampSendChat('/f �����'..Sex..' ��������� ������� � �������� �'..tid..' '..targrpnick..' | ���������: �������������')  
            end
            wait(200)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��� ����������� ������� - {58ACFA}1{FFFFFF}. ������ - {58ACFA}2{FFFFFF}.', -1)
                repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
                if isKeyJustPressed(0x31) then
                    sampSendChat('�������� �� ��������, ����� ���� �������� ���������� ��������.')
                    wait(2100)
                    sampSendChat('��� ������ �������� ����.')
                    wait(2100)
                    sampSendChat('/n /me ����(�) ���� � ���������, ����� ���� �����(�) ���')
                    wait(2100)
                    sampSendChat('/me ����'..Sex..' ���� � ���������, ����� ���� �����'..Sex..' ���')
                    wait(2100)
                    sampSendChat('�������� ���������, ��������� ���� � ���������� � ����� "�����".')
                    wait(2100)
                    sampSendChat('/n ������� ��������� ����� ����� �� ������� [Ctrl], �������� ���� [Alt].')
                    RunMotoExam = true
                    NextStepMoto = 1
                    while not MotoExamResume do
                        wait(0)
                        if MotoExamResume then
                            wait(1500)
                            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ����� ���� ��� ��������������, �������:', -1)
                            wait(1)
                            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ���� - {58ACFA}1{FFFFFF}, �� ���� - {58ACFA}2{FFFFFF}, ������ - {58ACFA}3{FFFFFF}.', -1)
                            repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
                            if isKeyJustPressed(0x31) then
                                sampSendChat('/me ���������'..Sex..' ����, ����� ���� ������'..Sex..' ������ � �����'..Sex..' ��������� ��')
                                wait(2100)
                                sampSendChat('/me ������'..Sex..' ��� � ������� �������')
                                wait(2100)
                                sampSendChat('/me ������'..Sex..' ������ ����� ������������ �������������, ����� ���� �������'..Sex..' �������')
                                wait(2100)
                                sampSendChat('/me ����� ���������� ����������, ��������� ������'..Sex..' �� � ������'..Sex..' ����')
                                wait(2100)
                                if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                                    sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������'..Sex..' ������� � �������� �'..tid..' '..targrpnick..' || ���������: �������������  || ���������: �������.')
                                else
                                    sampSendChat('/f ��������'..Sex..' ������� � �������� �'..tid..' '..targrpnick..' || ���������: �������������  || ���������: �������.') 
                                end
                                ExamEnd(1)
                                wait(2100)
                                sampSendChat('/exam')
                                if Toggle['AutoScreen'].v then TimeScreen() end
                                MotoExamResume = false
                                congr()
                            elseif isKeyJustPressed(0x32) then
                                sampSendChat('�� ��������� ������� ����� ������, ������������� �� ���������.')
                                wait(2100)
                                if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                                    sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������'..Sex..' ������� � �������� �'..tid..' '..targrpnick..' || ���������: �������������  || ���������: �� ������.')
                                else
                                    sampSendChat('/f ��������'..Sex..' ������� � �������� �'..tid..' '..targrpnick..' || ���������: �������������  || ���������: �� ������.') 
                                end
                                ExamEnd(2)
                                wait(2100)
                                sampSendChat('/exam')
                                MotoExamResume = false
                            elseif isKeyJustPressed(0x33) then
                                thisScript():reload()
                            end
                        end
                    end
                elseif isKeyJustPressed(0x32) then
                    thisScript():reload()
                end
        elseif isKeyJustPressed(0x32) then
            sampSendChat('� ��� �������� � �����������, � �� ���� ������� � ��� �������.')
            ExamEnd(2)
            wait(2000)
            sampSendChat('/exam')
        elseif isKeyJustPressed(0x33) then
            thisScript():reload()
        end
	end)
end

function bigcarExam()
	lua_thread.create(function()
        sampSendChat('������������, � ��������� ��������� '..rpnick..' � � ���� ��������� �������.')
        wait(2100)
        sampSendChat('���������� ��� ������� � ���.�����')
        wait(2100)
        sampSendChat('/n ������� �������: /pass '..myid..', ���. �����: /med '..myid)
        wait(200)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��������: {58ACFA}18+ ���{FFFFFF} � ��������� ���. ������ � {58ACFA}4 LvL{FFFFFF}', -1) wait(1)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��� ����������� ������� - {58ACFA}1{FFFFFF}. ���� �� �������, �� ������� - {58ACFA}2{FFFFFF}. ������ - {58ACFA}3{FFFFFF}.', -1)
        repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
        if isKeyJustPressed(0x31) then
            sampSendChat('/me ������'..Sex..' ����� � ����� �� ������� ����')
            wait(2100)
            sampSendChat('/me ������'..Sex..' ��� � ������� �������������, ����� ���� �������'..Sex..' ���')
            wait(2100)
            sampSendChat('�������� �� ���� ��� ����� ������������ ����� ��������.')
            wait(2100)
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' �����'..Sex..' ��������� ������� � �������� �'..tid..' '..targrpnick..' | ���������: �������� �/c.')
            else
                sampSendChat('/f �����'..Sex..' ��������� ������� � �������� �'..tid..' '..targrpnick..' | ���������: �������� �/c.') 
            end
            wait(200)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��� ����������� ������� - {58ACFA}1{FFFFFF}. ������ - {58ACFA}2{FFFFFF}.', -1)
                repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
                if isKeyJustPressed(0x31) then
                    sampSendChat('�������������� �� ����� �������� � �������� ���� ���������� ��������.')
                    wait(2100)
                    sampSendChat('��� ������ ����������� ������ ������������.')
                    wait(2100)
                    sampSendChat('/n /me ����������(�) ������ ������������')
                    wait(2100)
                    sampSendChat('/me ����������'..Sex..' ������ ������������')
                    wait(2100)
                    sampSendChat('�������� ���������, ��������� �� �������� ����� � �������� ���������� ��������.')
                    wait(2100)
                    sampSendChat('/n ������� ��������� ����� ����� �� ������� [Ctrl], �������� ���� [Alt].')
                    RunBigCarExam = true
                    NextStepBigCar = 1
                    while not BigCarExamResume do
                        wait(0)
                        if BigCarExamResume then
                            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ����� ��������� ����� ������� - {58ACFA}1{FFFFFF}. ������ - {58ACFA}2{FFFFFF}.', -1)
                            repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
                            if isKeyJustPressed(0x31) then
                                sampSendChat('������ ����������� ���� �� �����, ������ �� �����.')
                                wait(1500)
                                sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ����� ���� ��� ��������������, �������:', -1)
                                wait(1)
                                sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ���� - {58ACFA}1{FFFFFF}, �� ���� - {58ACFA}2{FFFFFF}, ������ - {58ACFA}3{FFFFFF}.', -1)
                                repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
                                if isKeyJustPressed(0x31) then
                                    sampSendChat('/me ���������'..Sex..' ����, ����� ���� ������'..Sex..' ������ � �����'..Sex..' ��������� ��')
                                    wait(2100)
                                    sampSendChat('/me ������'..Sex..' ��� � ������� �������')
                                    wait(2100)
                                    sampSendChat('/me ������'..Sex..' ������ ����� ������������ �������������, ����� ���� �������'..Sex..' �������')
                                    wait(2100)
                                    sampSendChat('/me ����� ���������� ����������, ��������� ������'..Sex..' �� � ������'..Sex..' ����')
                                    wait(2100)
                                    if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                                        sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������'..Sex..' ������� � �������� �'..tid..' '..targrpnick..' || ���������: �������� �/c || ���������: �������.')
                                    else
                                        sampSendChat('/f ��������'..Sex..' ������� � �������� �'..tid..' '..targrpnick..' || ���������: �������� �/c || ���������: �������.') 
                                    end
                                    ExamEnd(1)
                                    wait(2100)
                                    sampSendChat('/exam')
                                    if Toggle['AutoScreen'].v then TimeScreen() end
                                    BigCarExamResume = false
                                    congr()
                                elseif isKeyJustPressed(0x32) then
                                    sampSendChat('�� ��������� ������� ����� ������, ������������� �� ���������.')
                                    wait(2100)
                                    if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                                        sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������'..Sex..' ������� � �������� �'..tid..' '..targrpnick..' || ���������: �������� �/c || ���������: �� ������.')
                                    else
                                        sampSendChat('/f ��������'..Sex..' ������� � �������� �'..tid..' '..targrpnick..' || ���������: �������� �/c || ���������: �� ������.') 
                                    end
                                    ExamEnd(2)
                                    wait(2100)
                                    sampSendChat('/exam')
                                    BigCarExamResume = false
                                elseif isKeyJustPressed(0x33) then
                                    thisScript():reload()
                                end
                            elseif isKeyJustPressed(0x32) then
                                thisScript():reload()
                            end
                        end
                    end
                elseif isKeyJustPressed(0x32) then
                    thisScript():reload()
                end
        elseif isKeyJustPressed(0x32) then
            sampSendChat('� ��� �������� � �����������, � �� ���� ������� � ��� �������.')
            ExamEnd(2)
            wait(2000)
            sampSendChat('/exam')
        elseif isKeyJustPressed(0x33) then
            thisScript():reload()
        end
	end)
end

function SellLic(vid)
    lua_thread.create(function()
        sampSendChat('������������, ���� ����� '..rpnick..', � �������� ��������.')
        wait(2100)
        sampSendChat('����� �������� ������� ����������? �� ������ ��������� ��� �� ������?')
        wait(2100)
        sampSendChat('��������� �������� �� ������ ��������� - 20.000$, � �� ������ - 30.000$.')
        wait(1500)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��� ����������� ������� - {58ACFA}1{FFFFFF}. ������ - {58ACFA}2{FFFFFF}.', -1)
            repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
            if isKeyJustPressed(0x31) then
                sampSendChat('������, ���������� ��� ��� ������� � ���. �����.')
                wait(1500)
                sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��������: {58ACFA}18+ ���{FFFFFF} � ��������� ���. ������', -1) wait(1)
                sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��� ����������� ������� - {58ACFA}1{FFFFFF}. ���� �� �������, �� ������� - {58ACFA}2{FFFFFF}. ������ - {58ACFA}3{FFFFFF}.', -1)
                repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
                if isKeyJustPressed(0x31) then
                    sampSendChat('/do � ����� ���� ��������� �������� � ����������.')
                    wait(2100)
                    sampSendChat('/me ������'..Sex..' ���� � �������'..Sex..' �� ���� ������ ��������')
                    wait(2100)
                    sampSendChat('/me ����'..Sex..' � ���� �����, ����� ���� ��������'..Sex..' ��������')
                    wait(2100)
                    sampSendChat('/todo ��� ���� ��������*����� ���� �������'..Sex..' �������� �������� ��������')
                    wait(2100)
                    sampSendChat('/selllic '..tid..' '..vid)
                    if Toggle['AutoScreen'].v then TimeScreen() end
                elseif isKeyJustPressed(0x32) then
                    sampSendChat('� ��� �������� � �����������, � �� ���� ������� ��� ��������.')
                elseif isKeyJustPressed(0x33) then
                    thisScript():reload()
                end
            elseif isKeyJustPressed(0x32) then
                thisScript():reload()
            end
	end)
end

function sellinsurance()
    lua_thread.create(function()
        sampSendChat('������������, � ��������� ����� '..rpnick..'. �� ����� ���� ������-�� ������������ ���� ���������?')
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��� ����������� ������� - {58ACFA}1{FFFFFF}. ������ - {58ACFA}2{FFFFFF}.', -1)
        repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
        if isKeyJustPressed(0x31) then
            sampSendChat('������, ������������ ��� ��� �������, ���. ����� � ���.')
                sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��������: {58ACFA}18+ ���{FFFFFF} � ��������� ���. ������', -1) wait(1)
                sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ��� ����������� ������� - {58ACFA}1{FFFFFF}. ���� �� �������, �� ������� - {58ACFA}2{FFFFFF}. ������ - {58ACFA}3{FFFFFF}.', -1)
                repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
                if isKeyJustPressed(0x31) then
                    sampSendChat('/do ���� � �������� � �����������, �������� � ���������� � ������ ����.')
                    wait(2100)
                    sampSendChat('/me ������'..Sex..' ����, ������'..Sex..' ���������, ����� ���� �����'..Sex..' ��������� ��')
                    wait(2100)
                    sampSendChat('/me ���� ��������'..Sex..' ������ "License center at", ���� � �������')
                    wait(2100)
                    sampSendChat('/me ����� ������� ���������, �� ��������� ������'..Sex..' ����')
                    wait(2100)
                    sampSendChat('/me �������'..Sex..' ��������� �������� ��������')
                    wait(200)
                    sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������� ����: 10 ���� - {58ACFA}1{FFFFFF}, 30 ���� - {58ACFA}2{FFFFFF}, 60 ���� - {58ACFA}3', -1)
                    sampSetChatInputEnabled(true)
                    sampSetChatInputText('/insurance '..tid..' ')
                    repeat wait(0) until isKeyJustPressed(0x0D)
                    if Toggle['AutoScreen'].v then TimeScreen() end
                elseif isKeyJustPressed(0x32) then
                    sampSendChat('� ��� �������� � �����������, � �� ���� ������� ��� ���������.')
                elseif isKeyJustPressed(0x33) then
                    thisScript():reload()
                end
        elseif isKeyJustPressed(0x32) then
            thisScript():reload()
        end
	end)
end

function vehicleLC()
    lua_thread.create(function()
        if Toggle['LecF'].v then
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ������ ���� ����������, ������� � �������� ���... ')
                wait(2000)
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ...������ ��� "��������� � ������������ ������".')
                wait(2000)
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ���������� ����������� ����� ���������� "Premier" � ���������...')
                wait(2000)
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ..."�����������" � ���������� �����������, ������ � ������� ��������..')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ���� �� ������� ���������� ��� ����������, �� �������� �������.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ������� "Maverick" ����������� ����� � ���������...')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ... "��������" � ����, �� ������ � ������� �����.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' �� ��������� ����� ������� �� �������� �������.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������� ��� ������� ���������� ���������� �������� ����������...')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ...�� ��������: ������������ ����� ������� ����� � ����� ������.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' �� �������� � ������������ ����� ���������� ������ ������.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ������� �� ��������!')
            else
                sampSendChat('/f ������ ���� ����������, ������� � �������� ���... ')
                wait(2000)
                sampSendChat('/f ...������ ��� "��������� � ������������ ������".')
                wait(2000)
                sampSendChat('/f ���������� ����������� ����� ���������� "Premier" � ���������...')
                wait(2000)
                sampSendChat('/f ..."�����������" � ���������� �����������, ������ � ������� ��������..')
                wait(2000)
                sampSendChat('/f ���� �� ������� ���������� ��� ����������, �� �������� �������.')
                wait(2000)
                sampSendChat('/f ������� "Maverick" ����������� ����� � ���������...')
                wait(2000)
                sampSendChat('/f ... "��������" � ����, �� ������ � ������� �����.')
                wait(2000)
                sampSendChat('/f �� ��������� ����� ������� �� �������� �������.')
                wait(2000)
                sampSendChat('/f ��������� ��� ������� ���������� ���������� �������� ����������...')
                wait(2000)
                sampSendChat('/f ...�� ��������: ������������ ����� ������� ����� � ����� ������.')
                wait(2000)
                sampSendChat('/f �� �������� � ������������ ����� ���������� ������ ������.')
                wait(2000)
                sampSendChat('/f ������� �� ��������!')
            end
            if Toggle['AutoScreen'].v then TimeScreen() end
        else
            sampSendChat('������ ���� ����������, ������� � �������� ���... ')
            wait(2000)
            sampSendChat('...������ ��� "��������� � ������������ ������".')
            wait(2000)
            sampSendChat('���������� ����������� ����� ���������� "Premier" � ���������...')
            wait(2000)
            sampSendChat('..."�����������" � ���������� �����������, ������ � ������� ��������..')
            wait(2000)
            sampSendChat('���� �� ������� ���������� ��� ����������, �� �������� �������.')
            wait(2000)
            sampSendChat('������� "Maverick" ����������� ����� � ���������...')
            wait(2000)
            sampSendChat('... "��������" � ����, �� ������ � ������� �����.')
            wait(2000)
            sampSendChat('�� ��������� ����� ������� �� �������� �������.')
            wait(2000)
            sampSendChat('��������� ��� ������� ���������� ���������� �������� ����������...')
            wait(2000)
            sampSendChat('...�� ��������: ������������ ����� ������� ����� � ����� ������.')
            wait(2000)
            sampSendChat('�� �������� � ������������ ����� ���������� ������ ������.')
            wait(2000)
            sampSendChat('������� �� ��������!')
            if Toggle['AutoScreen'].v then TimeScreen() end
        end
	end)
end

function EticetSub()
	lua_thread.create(function()
        if Toggle['LecF'].v then
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ������ ���� ����������,������� � �������� ��� ������ ��� "������ � ������������".')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������� ������ ������� ������������� � ���������, ��������� ��������� �� "��".')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ����������� ����������� ���������� � �������...')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ...�������� ��� ����������� ������������� ������.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' �� ������ ����������� ��� �������� ��� ������.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ���������� ����������� ������������ ����������� ������� �� ������� �����.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������� ������ ���������� � ����������� �� "��".')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������� ����� ����� ������������� � ���������,...')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ...�� �������� ������ �����������, �� "��".')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' �� ��������� ������������ �� �������� �������.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ������� �� ��������!')
            else
                sampSendChat('/f ������ ���� ����������,������� � �������� ��� ������ ��� "������ � ������������".')
                wait(2000)
                sampSendChat('/f ��������� ������ ������� ������������� � ���������, ��������� ��������� �� "��".')
                wait(2000)
                sampSendChat('/f ����������� ����������� ���������� � �������...')
                wait(2000)
                sampSendChat('/f ...�������� ��� ����������� ������������� ������.')
                wait(2000)
                sampSendChat('/f �� ������ ����������� ��� �������� ��� ������.')
                wait(2000)
                sampSendChat('/f ���������� ����������� ������������ ����������� ������� �� ������� �����.')
                wait(2000)
                sampSendChat('/f ��������� ������ ���������� � ����������� �� "��".')
                wait(2000)
                sampSendChat('/f ��������� ����� ����� ������������� � ���������,...')
                wait(2000)
                sampSendChat('/f ...�� �������� ������ �����������, �� "��".')
                wait(2000)
                sampSendChat('/f �� ��������� ������������ �� �������� �������.')
                wait(2000)
                sampSendChat('/f ������� �� ��������!')
            end
            if Toggle['AutoScreen'].v then TimeScreen() end 
        else
            sampSendChat('������ ���� ����������,������� � �������� ��� ������ ��� "������ � ������������".')
            wait(2000)
            sampSendChat('��������� ������ ������� ������������� � ���������, ��������� ��������� �� "��".')
            wait(2000)
            sampSendChat('����������� ����������� ���������� � �������...')
            wait(2000)
            sampSendChat('...�������� ��� ����������� ������������� ������.')
            wait(2000)
            sampSendChat('�� ������ ����������� ��� �������� ��� ������.')
            wait(2000)
            sampSendChat('���������� ����������� ������������ ����������� ������� �� ������� �����.')
            wait(2000)
            sampSendChat('��������� ������ ���������� � ����������� �� "��".')
            wait(2000)
            sampSendChat('��������� ����� ����� ������������� � ���������,...')
            wait(2000)
            sampSendChat('...�� �������� ������ �����������, �� "��".')
            wait(2000)
            sampSendChat('�� ��������� ������������ �� �������� �������.')
            wait(2000)
            sampSendChat('������� �� ��������!')
            if Toggle['AutoScreen'].v then TimeScreen() end
        end
	end)
end

function RulesUseR()
	lua_thread.create(function()
        if Toggle['LecF'].v then
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ������ ���� ����������,������� � �������� ��� "������� ������������� �����".')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������� ����� ����� ������������ ������ ����������� � ����� �����.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ���������� ����������� ������������� ������� �����, ���������� � ����� ��������� � �����.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ���������� ����������� ������������ ��������� � �����.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ���������� ����������� ��������� ����� 3 � ����� ���.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ���� 3-� � ����� �����')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' �� ���� � ����� ��������� ���� �������� �������.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ������� ������� �� ��������!')
            else
                sampSendChat('/f ������ ���� ����������,������� � �������� ��� "������� ������������� �����".')
                wait(2000)
                sampSendChat('/f ��������� ����� ����� ������������ ������ ����������� � ����� �����.')
                wait(2000)
                sampSendChat('/f ���������� ����������� ������������� ������� �����, ���������� � ����� ��������� � �����.')
                wait(2000)
                sampSendChat('/f ���������� ����������� ������������ ��������� � �����.')
                wait(2000)
                sampSendChat('/f ���������� ����������� ��������� ����� 3 � ����� ���.')
                wait(2000)
                sampSendChat('/fn ���� 3-� � ����� �����')
                wait(2000)
                sampSendChat('/f �� ���� � ����� ��������� ���� �������� �������.')
                wait(2000)
                sampSendChat('/f ������� ������� �� ��������!')
            end
            if Toggle['AutoScreen'].v then TimeScreen() end 
        else
            sampSendChat('������ ���� ����������,������� � �������� ��� "������� ������������� �����".')
            wait(2000)
            sampSendChat('��������� ����� ����� ������������ ������ ����������� � ����� �����.')
            wait(2000)
            sampSendChat('���������� ����������� ������������� ������� �����, ���������� � ����� ��������� � �����.')
            wait(2000)
            sampSendChat('���������� ����������� ������������ ��������� � �����.')
            wait(2000)
            sampSendChat('���������� ����������� ��������� ����� 3 � ����� ���.')
            wait(2000)
            sampSendChat('/n ���� 3-� � ����� �����')
            wait(2000)
            sampSendChat('�� ���� � ����� ��������� ���� �������� �������.')
            wait(2000)
            sampSendChat('������� ������� �� ��������!')
            if Toggle['AutoScreen'].v then TimeScreen() end
        end
	end)
end

function GeneralRules()
	lua_thread.create(function()
        if Toggle['LecF'].v then
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ������ ���� ����������,������� � �������� ��� ������ ���...')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ..."�������� ������� � ����������� ��".')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ����������� ������������� ������ ��������� ����������� ������� ����.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ����������� ��������� ������ ��� ���� ������������� ������ � �������� ����.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ����������� ��������� ����������� �������� � ������� �����.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��� ���������� ������� ��������� ����������� �����-���, ��� ��������� �� ������� �������.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ���������� ������� ��������� ����������� ����� �� � ���� ���������������� ����������.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������� ������ ��������� ������ �������� � ����������� � ������� ��������.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������� �� ����� ����� ������������ ������� �����������, ������...')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ...���� ��� �� ������������ ����������� �������.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ������� ������� �� ��������!')
            else 
                sampSendChat('/f ������ ���� ����������,������� � �������� ��� ������ ���...')
                wait(2000)
                sampSendChat('/f ..."�������� ������� � ����������� ��".')
                wait(2000)
                sampSendChat('/f ����������� ������������� ������ ��������� ����������� ������� ����.')
                wait(2000)
                sampSendChat('/f ����������� ��������� ������ ��� ���� ������������� ������ � �������� ����.')
                wait(2000)
                sampSendChat('/f ����������� ��������� ����������� �������� � ������� �����.')
                wait(2000)
                sampSendChat('/f ��� ���������� ������� ��������� ����������� �����-���, ��� ��������� �� ������� �������.')
                wait(2000)
                sampSendChat('/f ���������� ������� ��������� ����������� ����� �� � ���� ���������������� ����������.')
                wait(2000)
                sampSendChat('/f ��������� ������ ��������� ������ �������� � ����������� � ������� ��������.')
                wait(2000)
                sampSendChat('/f ��������� �� ����� ����� ������������ ������� �����������, ������...')
                wait(2000)
                sampSendChat('/f ...���� ��� �� ������������ ����������� �������.')
                wait(2000)
                sampSendChat('/f ������� ������� �� ��������!') 
            end
            if Toggle['AutoScreen'].v then TimeScreen() end
        else
            sampSendChat('������ ���� ����������,������� � �������� ��� ������ ���...')
            wait(2000)
            sampSendChat('..."�������� ������� � ����������� ��".')
            wait(2000)
            sampSendChat('����������� ������������� ������ ��������� ����������� ������� ����.')
            wait(2000)
            sampSendChat('����������� ��������� ������ ��� ���� ������������� ������ � �������� ����.')
            wait(2000)
            sampSendChat('����������� ��������� ����������� �������� � ������� �����.')
            wait(2000)
            sampSendChat('��� ���������� ������� ��������� ����������� �����-���, ��� ��������� �� ������� �������.')
            wait(2000)
            sampSendChat('���������� ������� ��������� ����������� ����� �� � ���� ���������������� ����������.')
            wait(2000)
            sampSendChat('��������� ������ ��������� ������ �������� � ����������� � ������� ��������.')
            wait(2000)
            sampSendChat('��������� �� ����� ����� ������������ ������� �����������, ������...')
            wait(2000)
            sampSendChat('...���� ��� �� ������������ ����������� �������.')
            wait(2000)
            sampSendChat('������� ������� �� ��������!')
            if Toggle['AutoScreen'].v then TimeScreen() end
        end
	end)
end

function RulesUseDesk()
    lua_thread.create(function()
        if Toggle['LecF'].v then
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ������ ���� ����������,������� � �������� ��� ������� ������������� �����.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' �� ����� ����������� ������ ������ "����������� ���������" � "���������".')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' �� ��������� ����� ������� �� �������� ������� �������.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' 2/3')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������� ������ ������������ ����� ������ ��� ����������� �������...')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ...�������� �� � ���������� ��� �����������.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' �� ��������� ����� ������� �� �������� �������.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' �� ��������� �������� ��� �������������� ��������� �� �����.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ��������� ����� ������ �������.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ����� �������!')
            else 
                sampSendChat('/f ������ ���� ����������,������� � �������� ��� ������� ������������� �����.')
                wait(2000)
                sampSendChat('/f �� ����� ����������� ������ ������ "����������� ���������" � "���������".')
                wait(2000)
                sampSendChat('/f �� ��������� ����� ������� �� �������� ������� �������.')
                wait(2000)
                sampSendChat('/fn 2/3')
                wait(2000)
                sampSendChat('/f ��������� ������ ������������ ����� ������ ��� ����������� �������...')
                wait(2000)
                sampSendChat('/f ...�������� �� � ���������� ��� �����������.')
                wait(2000)
                sampSendChat('/f �� ��������� ����� ������� �� �������� �������.')
                wait(2000)
                sampSendChat('/f �� ��������� �������� ��� �������������� ��������� �� �����.')
                wait(2000)
                sampSendChat('/f ��������� ����� ������ �������.')
                wait(2000)
                sampSendChat('/f ����� �������!')
            end
            if Toggle['AutoScreen'].v then TimeScreen() end 
        else
            sampSendChat('������ ���� ����������,������� � �������� ��� ������� ������������� �����.')
            wait(2000)
            sampSendChat('�� ����� ����������� ������ ������ "����������� ���������" � "���������".')
            wait(2000)
            sampSendChat('�� ��������� ����� ������� �� �������� ������� �������.')
            wait(2000)
            sampSendChat('/n 2/3')
            wait(2000)
            sampSendChat('��������� ������ ������������ ����� ������ ��� ����������� �������...')
            wait(2000)
            sampSendChat('...�������� �� � ���������� ��� �����������.')
            wait(2000)
            sampSendChat('�� ��������� ����� ������� �� �������� �������.')
            wait(2000)
            sampSendChat('�� ��������� �������� ��� �������������� ��������� �� �����.')
            wait(2000)
            sampSendChat('��������� ����� ������ �������.')
            wait(2000)
            sampSendChat('����� �������!')
            if Toggle['AutoScreen'].v then TimeScreen() end
        end
	end)
end

function rangup(arg)
    lua_thread.create(function()
        if arg == 2 then
            sampSendChat('/do � ������� ����� �������.')
            wait(2000)
            sampSendChat('/me ������'..Sex..' �������')
            wait(2000)
            sampSendChat('/do �� ��������� ������� "������ �����������".')
            wait(2000)
            sampSendChat('/me ������'..Sex..' ����������, ����� �����'..Sex..' ������ "��������� � ���������"')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������� {58ACFA}id{FFFFFF} ����������', -1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/rang ')
        elseif arg == 1 then
            sampSendChat('/do � ������� ����� �������.')
            wait(2000)
            sampSendChat('/me ������'..Sex..' �������')
            wait(2000)
            sampSendChat('/do �� ��������� ������� "������ �����������".')
            wait(2000)
            sampSendChat('/me ������'..Sex..' ����������, ����� �����'..Sex..' ������ "��������� � ���������"')
            wait(2000)
            sampSendChat('/rang '..tid)
        end
	end)
end

function giveskin(arg)
    lua_thread.create(function()
        if arg == 2 then
            sampSendChat('/do �� ����� ����� �����.')
            wait(2000)
            sampSendChat('/me �������'..Sex..' � ����� �����, ��������'..Sex..' �� �����')
            wait(2000)
            sampSendChat('/me ������'..Sex..' �������� ������� ������, ����� ���� �������'..Sex..' �������� ��������')
            wait(2000)
            sampSendChat('/todo ��� ���*�������� �����')
            wait(2000)
            sampSendChat('/me �������'..Sex..' ����� �� �����')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������� {58ACFA}id{FFFFFF} ����������', -1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/setskin ')
        elseif arg == 1 then
            sampSendChat('/do �� ����� ����� �����.')
            wait(2000)
            sampSendChat('/me �������'..Sex..' � ����� �����, ��������'..Sex..' �� �����')
            wait(2000)
            sampSendChat('/me ������'..Sex..' �������� ������� ������, ����� ���� �������'..Sex..' �������� ��������')
            wait(2000)
            sampSendChat('/todo ��� ���*�������� �����')
            wait(2000)
            sampSendChat('/me �������'..Sex..' ����� �� �����')
            wait(2000)
            sampSendChat('/setskin '..tid)
        end
	end)
end

function givewarn(arg)
	lua_thread.create(function()
        if arg == 2 then
            sampSendChat('/me ������'..Sex..' �� ������ ������� ���, �������'..Sex..' ���')
            wait(2000)
            if Radio['Gender'].v == 1 then
                sampSendChat('/me ����� � ������ �����������, ����� ������� ����������, �������� ���� �������� ������� "�������"')
            else
                sampSendChat('/me ����� � ������ �����������, ����� ������� ����������, �������� ���� ��������� ������� "�������"')
            end
            wait(2000)
            sampSendChat('/do ������� ������ �������� � ������ ���� ����������.')
            wait(2000)
            sampSendChat('/me ��������'..Sex..' ���, �����'..Sex..' ��� � ������')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������� {58ACFA}id{FFFFFF} ���������� � {58ACFA}�������{FFFFFF}', -1) wait(1)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������ �������������: {58ACFA}/fwarn [ID] �� | ������ ['..date..']', -1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/fwarn  ['..date..']')            
        elseif arg == 1 then
            sampSendChat('/me ������'..Sex..' �� ������ ������� ���, �������'..Sex..' ���')
            wait(2000)
            if Radio['Gender'].v == 1 then
                sampSendChat('/me ����� � ������ �����������, ����� ������� ����������, �������� ���� �������� ������� "�������"')
            else
                sampSendChat('/me ����� � ������ �����������, ����� ������� ����������, �������� ���� ��������� ������� "�������"')
            end
            wait(2000)
            sampSendChat('/do ������� ������ �������� � ������ ���� ����������.')
            wait(2000)
            sampSendChat('/me ��������'..Sex..' ���, �����'..Sex..' ��� � ������')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������� {58ACFA}�������{FFFFFF}', -1) wait(1)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������ �������������: {58ACFA}/fwarn '..tid..' �� | ������ ['..date..']', -1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/fwarn '..tid..'  ['..date..']')
        end
	end)
end

function givewarnoff()
	lua_thread.create(function()
        sampSendChat('/me ������'..Sex..' �� ������ ������� ���, �������'..Sex..' ���')
        wait(2000)
        if Radio['Gender'].v == 1 then
            sampSendChat('/me ����� � ������ �����������, ����� ������� ����������, �������� ���� �������� ������� "�������"')
        else
            sampSendChat('/me ����� � ������ �����������, ����� ������� ����������, �������� ���� ��������� ������� "�������"')
        end
        wait(2000)
        sampSendChat('/do ������� ������ �������� � ������ ���� ����������.')
        wait(2000)
        sampSendChat('/me ��������'..Sex..' ���, �����'..Sex..' ��� � ������')
        wait(500)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������� {58ACFA}Nick_Name{FFFFFF} ���������� � {58ACFA}�������{FFFFFF}', -1) wait(1)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������ �������������: {58ACFA}/fwarnoff Banana_Blackstone �� | ������ ['..date..']', -1)
        sampSetChatInputEnabled(true)
        sampSetChatInputText('/fwarnoff  ['..date..']') 
	end)
end

function takeoffwarn(arg)
	lua_thread.create(function()
        if arg == 2 then
            sampSendChat('/me ������'..Sex..' �� ������ ������� ���, �������'..Sex..' ���')
            wait(2000)
            if Radio['Gender'].v == 1 then
                sampSendChat('/me ����� � ������ �����������, ����� ������� ����������, �������� ���� �������� ������� "������ ��������"')
            else
                sampSendChat('/me ����� � ������ �����������, ����� ������� ����������, �������� ���� ��������� ������� "������ ��������"')
            end
            wait(2000)
            sampSendChat('/do ������� ������ �������� � ������ ���� ����������.')
            wait(2000)
            sampSendChat('/me ��������'..Sex..' ���, �����'..Sex..' ��� � ������')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������� {58ACFA}id{FFFFFF} ���������� � {58ACFA}�������{FFFFFF}', -1) wait(1)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������ �������������: {58ACFA}/unfwarn [ID] �� | ��������� ['..date..']', -1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/unfwarn  ['..date..']') 
        elseif arg == 1 then
            sampSendChat('/me ������'..Sex..' �� ������ ������� ���, �������'..Sex..' ���')
            wait(2000)
            if Radio['Gender'].v == 1 then
                sampSendChat('/me ����� � ������ �����������, ����� ������� ����������, �������� ���� �������� ������� "������ ��������"')
            else
                sampSendChat('/me ����� � ������ �����������, ����� ������� ����������, �������� ���� ��������� ������� "������ ��������"')
            end
            wait(2000)
            sampSendChat('/do ������� ������ �������� � ������ ���� ����������.')
            wait(2000)
            sampSendChat('/me ��������'..Sex..' ���, �����'..Sex..' ��� � ������')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������� {58ACFA}�������{FFFFFF}', -1) wait(1)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������ �������������: {58ACFA}/unfwarn '..tid..' �� | ��������� ['..date..']', -1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/unfwarn '..tid..'  ['..date..']') 
        end
	end)
end

function uninvite(arg)
	lua_thread.create(function()
        if arg == 2 then
            sampSendChat('/me ������'..Sex..' �� ������ ������� ���, �������'..Sex..' ���')
            wait(2000)
            if Radio['Gender'].v == 1 then
                sampSendChat('/me ����� � ������ �����������, ����� ������� ����������, �������� ���� �������� ������� "����������"')
            else
                sampSendChat('/me ����� � ������ �����������, ����� ������� ����������, �������� ���� ��������� ������� "����������"')
            end
            wait(2000)
            sampSendChat('/do ������� ������������ ������ ���� ����������.')
            wait(2000)
            sampSendChat('/me ��������'..Sex..' ���, �����'..Sex..' ��� � ������')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������� {58ACFA}id{FFFFFF} ���������� � {58ACFA}�������{FFFFFF}', -1) wait(1)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������ �������������: {58ACFA}/uninvite [ID] �� | ����.���������� ['..date..']', -1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/uninvite  ['..date..']') 
        elseif arg == 1 then
            sampSendChat('/me ������'..Sex..' �� ������ ������� ���, �������'..Sex..' ���')
            wait(2000)
            if Radio['Gender'].v == 1 then
                sampSendChat('/me ����� � ������ �����������, ����� ������� ����������, �������� ���� �������� ������� "����������"')
            else
                sampSendChat('/me ����� � ������ �����������, ����� ������� ����������, �������� ���� ��������� ������� "����������"')
            end
            wait(2000)
            sampSendChat('/do ������� ������������ ������ ���� ����������.')
            wait(2000)
            sampSendChat('/me ��������'..Sex..' ���, �����'..Sex..' ��� � ������')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������� {58ACFA}�������{FFFFFF}', -1) wait(1)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������ �������������: {58ACFA}/uninvite '..tid..' �� | ����.���������� ['..date..']', -1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/uninvite '..tid..'  ['..date..']')
        end
	end)
end

function uninviteoff()
	lua_thread.create(function()
        sampSendChat('/me ������'..Sex..' �� ������ ������� ���, �������'..Sex..' ���')
        wait(2000)
        if Radio['Gender'].v == 1 then
            sampSendChat('/me ����� � ������ �����������, ����� ������� ����������, �������� ���� �������� ������� "����������"')
        else
            sampSendChat('/me ����� � ������ �����������, ����� ������� ����������, �������� ���� ��������� ������� "����������"')
        end
        wait(2000)
        sampSendChat('/do ������� ������������ ������ ���� ����������.')
        wait(2000)
        sampSendChat('/me ��������'..Sex..' ���, �����'..Sex..' ��� � ������')
        wait(500)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������� {58ACFA}Nick_Name{FFFFFF} ���������� � {58ACFA}�������{FFFFFF}', -1) wait(1)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������ �������������: {58ACFA}/uninviteoff Banana_Blackstone �� | ����.���������� ['..date..']', -1)
        sampSetChatInputEnabled(true)
        sampSetChatInputText('/uninviteoff  ['..date..']') 
	end)
end

function gobl(arg)
	lua_thread.create(function()
        if arg == 2 then
            sampSendChat('/me ������'..Sex..' �� ������ ������� ���, �������'..Sex..' ���')
            wait(2000)
            if Radio['Gender'].v == 1 then
                sampSendChat('/me ����� � ���� ������ ���������, ����� ���� ����� �� ������� "������ ������"')
            else
                sampSendChat('/me ����� � ���� ������ ���������, ����� ���� ������ �� ������� "������ ������"')
            end
            wait(2000)
            sampSendChat('/me ������'..Sex..' ������ �� ����������, ����� ���� �����'..Sex..' ������ "��������"')
            wait(2000)
            sampSendChat('/do ���� ��������...')
            wait(2000)
            sampSendChat('/do ������� �������� � ������ ������.')
            wait(2000)
            sampSendChat('/me ��������'..Sex..' ���, �����'..Sex..' ��� � ������')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������� {58ACFA}id{FFFFFF} ����������', -1) wait(1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/black ') 
        elseif arg == 1 then
            sampSendChat('/me ������'..Sex..' �� ������ ������� ���, �������'..Sex..' ���')
            wait(2000)
            if Radio['Gender'].v == 1 then
                sampSendChat('/me ����� � ���� ������ ���������, ����� ���� ����� �� ������� "������ ������"')
            else
                sampSendChat('/me ����� � ���� ������ ���������, ����� ���� ������ �� ������� "������ ������"')
            end
            wait(2000)
            sampSendChat('/me ������'..Sex..' ������ �� ����������, ����� ���� �����'..Sex..' ������ "��������"')
            wait(2000)
            sampSendChat('/do ���� ��������...')
            wait(2000)
            sampSendChat('/do ������� �������� � ������ ������.')
            wait(2000)
            sampSendChat('/me ��������'..Sex..' ���, �����'..Sex..' ��� � ������')
            wait(2000)
            sampSendChat('/black '..tid) 
        end
	end)
end

function gobloff(arg)
	lua_thread.create(function()
        sampSendChat('/me ������'..Sex..' �� ������ ������� ���, �������'..Sex..' ���')
        wait(2000)
        if Radio['Gender'].v == 1 then
            sampSendChat('/me ����� � ���� ������ ���������, ����� ���� ����� �� ������� "������ ������"')
        else
            sampSendChat('/me ����� � ���� ������ ���������, ����� ���� ������ �� ������� "������ ������"')
        end
        wait(2000)
        sampSendChat('/me ������'..Sex..' ������ �� ����������, ����� ���� �����'..Sex..' ������ "��������"')
        wait(2000)
        sampSendChat('/do ���� ��������...')
        wait(2000)
        sampSendChat('/do ������� �������� � ������ ������.')
        wait(2000)
        sampSendChat('/me ��������'..Sex..' ���, �����'..Sex..' ��� � ������')
        wait(500)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������� {58ACFA}Nick_Name{FFFFFF} ����������', -1) wait(1)
        --sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������ �������������: {58ACFA}/uninviteoff Banana_Blackstone �� | ����.���������� ['..date..']', -1)
        sampSetChatInputEnabled(true)
        sampSetChatInputText('/offblack ') 
	end)
end

function backbl(arg)
    lua_thread.create(function()
        if arg == 2 then
            if Radio['Gender'].v == 1 then
                sampSendChat('/me ������ �������, ����� ���� ����� � ������ "׸���� ������ ���������"')
            else
                sampSendChat('/me ������� �������, ����� ���� ����� � ������ "׸���� ������ ���������"')
            end        
            wait(2000)
            sampSendChat('/me �����'..Sex..' �� ������ "�����", ����� ���� ����'..Sex..' ��� � ������� �������� � ����������� ����, ����� �����'..Sex..' "�����"')
            wait(2000)
            sampSendChat('/do ������� ������ ������ ������� ��������.')
            wait(2000)
            sampSendChat('/do ������ ���� ������ �� ������ �������� ������� ������: "��� �������" ������. � ���� �� ���� ���� ������ ��������: "�������" � "�������".')
            wait(2000)
            sampSendChat('/me �����'..Sex..' �� ������ "�������" , ����� �����'..Sex..' ������� � ������')
            wait(2000)
            sampSendChat('/do �� ������ �������� ������� �����������: "��� �������" ������� �� ������� ������ ���������.')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������� �������: {58ACFA}/offblack {FFFFFF}��� {58ACFA}/black', -1) wait(1)
            sampSetChatInputEnabled(true) 
        elseif arg == 1 then
            if Radio['Gender'].v == 1 then
                sampSendChat('/me ������ �������, ����� ���� ����� � ������ "׸���� ������ ���������"')
            else
                sampSendChat('/me ������� �������, ����� ���� ����� � ������ "׸���� ������ ���������"')
            end        
            wait(2000)
            sampSendChat('/me �����'..Sex..' �� ������ "�����", ����� ���� ����'..Sex..' ��� � ������� �������� � ����������� ����, ����� �����'..Sex..' "�����"')
            wait(2000)
            sampSendChat('/do ������� ������ ������ ������� ��������.')
            wait(2000)
            sampSendChat('/do ������ ���� ������ �� ������ �������� ������� ������: "'..targrpnick..'" ������. � ���� �� ���� ���� ������ ��������: "�������" � "�������".')
            wait(2000)
            sampSendChat('/me �����'..Sex..' �� ������ "�������" , ����� �����'..Sex..' ������� � ������')
            wait(2000)
            sampSendChat('/do �� ������ �������� ������� �����������: "'..targrpnick..'" ������� �� ������� ������ ���������.')
            wait(2000)
            sampSendChat('/black '..tid)
        end
	end)
end

function inviteFunc(st)
    lua_thread.create(function()
        if st == 1 then
            sampSendChat('������, �� ��� ���������! �������� ������ ����� � ��������.')
            wait(2000)
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ������� ����� ��������� �������� �� ����������.')
            else
                sampSendChat('/f ������� ����� ��������� �������� �� ����������.')
            end
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ���� �� ����� ��� �����������, ������� - {58ACFA}1{FFFFFF}. ���� ��� - {58ACFA}2{FFFFFF}.', -1)
            repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
            if isKeyJustPressed(0x31) then
                sampSendChat('/do �� ����� ����� �����.')
                wait(2000)
                sampSendChat('/do �� ��������� ������� "������ �����������"')
                wait(2000)
                sampSendChat('/me ������'..Sex..' ����������, ����� �����'..Sex..' ������ "��������� � ���������"')
                wait(200)
                sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������� {58ACFA}id{FFFFFF} ������', -1) wait(1)
                sampSetChatInputEnabled(true)
                sampSetChatInputText('/invite ')
                congr()
            elseif isKeyJustPressed(0x32) then
            end
        elseif st == 2 then
            sampSendChat('/do �� ����� ����� �����.')
            wait(2000)
            sampSendChat('/do �� ��������� ������� "������ �����������"')
            wait(2000)
            sampSendChat('/me ������'..Sex..' ����������, ����� �����'..Sex..' ������ "��������� � ���������"')
            wait(200)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} � ������� {58ACFA}id{FFFFFF} ������', -1) wait(1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/invite ')
            congr()
        elseif st == 3 then
            sampSendChat('/do �� ����� ����� �����.')
            wait(2000)
            sampSendChat('/do �� ��������� ������� "������ �����������"')
            wait(2000)
            sampSendChat('/me ������'..Sex..' ����������, ����� �����'..Sex..' ������ "��������� � ���������"')
            wait(2000)
            sampSendChat('/invite '..tid)
        end
    end)
end

function congr()
    lua_thread.create(function()
        repeat wait(0) until isKeyJustPressed(0x0D) or isKeyJustPressed(0x1B) or isKeyJustPressed(0x75)
            if isKeyJustPressed(0x0D) then
                sampSendChat('����������!')
            elseif isKeyJustPressed(0x1B) or isKeyJustPressed(0x75) then
            end
    end)
end

function latest_update()
	sampShowDialog(0, '{58ACFA}AutoSchool Assist', '{FFFFFF}� ��� ������ ������ �������', '�������')
end









function imgui.TextRGB(text, render_text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
            local a = bit.band(bit.rshift(argb, 24), 0xFF)
            local r = bit.band(bit.rshift(argb, 16), 0xFF)
            local g = bit.band(bit.rshift(argb, 8), 0xFF)
            local b = bit.band(argb, 0xFF)
            return a, r, g, b
    end

    local getcolor = function(color)
            if color:sub(1, 6):upper() == 'SSSSSS' then
                    local r, g, b = colors[1].x, colors[1].y, colors[1].z
                    local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
                    return ImVec4(r, g, b, a / 255)
            end
            local color = type(color) == 'string' and tonumber(color, 16) or color
            if type(color) ~= 'number' then return end
            local r, g, b, a = explode_argb(color)
            return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text)
            for w in text:gmatch('[^\r\n]+') do
                local textsize = w:gsub('{.-}', '')
                local text_width = imgui.CalcTextSize(u8(textsize))
                    local text, colors_, m = {}, {}, 1
                    w = w:gsub('{(......)}', '{%1FF}')
                    while w:find('{........}') do
                            local n, k = w:find('{........}')
                            local color = getcolor(w:sub(n + 1, k - 1))
                            if color then
                                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                                    colors_[#colors_ + 1] = color
                                    m = n
                            end
                            w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
                    end
                    local length = imgui.CalcTextSize(u8(w))
                    if render_text == 2 then
                            imgui.NewLine()
                            imgui.SameLine(width / 2 - ( length.x / 2 ))
                    elseif render_text == 3 then
                            imgui.NewLine()
                            imgui.SameLine(width - length.x - 5 )
                    end
                    if text[0] then
                            for i, k in pairs(text) do
                                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                                    imgui.SameLine(nil, 0)
                            end
                            imgui.NewLine()
                    else imgui.Text(u8(w)) end
            end
    end

    render_text(text)
end

function makeScreen(disable) -- ���� �������� true, ��������� � ��� ����� ������
    if disable then displayHud(false) sampSetChatDisplayMode(0) end
    require('memory').setuint8(sampGetBase() + 0x119CBC, 1)
    if disable then displayHud(true) sampSetChatDisplayMode(2) end
end

function imgui.TextQuestion(text)
    imgui.TextDisabled(fa.ICON_QUESTION_CIRCLE_O.. '') 
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end