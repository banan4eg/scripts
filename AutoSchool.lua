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

arr_rang = {u8'Стажер', u8'Консультант', u8'Экзаменатор', u8'Мл. Инструктор', u8'Инструктор', u8'Менеджер', u8'Зам. Директора', u8'Директор'}
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
                sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Доступна {58ACFA}новая версия {FFFFFF}скрипта', -1)
                sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Обновить скрипт можно в меню, во вкладке "{58ACFA}О скрипте{FFFFFF}"', -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)

    --repeat	wait(0)	until sampIsLocalPlayerSpawned()
    while true do wait(0)

 -- Dincamic variables --
    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if Radio['Gender'].v == 1 then Sex = '' SexL = '' else Sex = 'а' SexL = 'ла' end
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
    if math.sqrt( (ax - bx) ^ 5 + (ay - by) ^ 5 + (az - bz) ^ 5 ) < 10 and NextStepCar == 1 then -- 5 - радиус срабатывания
    wait(1000)
        sampSendChat("Проедьте по лежачим полицейским до конусов. Затем змейкой вокруг конусов.")
        NextStepCar = 2
    elseif math.sqrt( (ax - ex) ^ 5 + (ay - ey) ^ 5 + (az - ez) ^ 5 ) < 10 and NextStepCar == 2 then -- 5 - радиус срабатывания
    wait(1000)
        sampSendChat("Соблюдайте указания стрелок на асфальте и объезжайте конусы змейкой.")
        NextStepCar = 3
    elseif math.sqrt( (ax - qx) ^ 5 + (ay - qy) ^ 5 + (az - qz) ^ 5 ) < 10 and NextStepCar == 3 then -- 5 - радиус срабатывания\
    wait(1000)
        sampSendChat("Теперь поставьте машину в обозначенную область.")
        NextStepCar = 4
    elseif math.sqrt( (ax - wx) ^ 5 + (ay - wy) ^ 5 + (az - wz) ^ 5 ) < 10 and NextStepCar == 4 then -- 5 - радиус срабатывания\
    wait(1000)
        sampSendChat("Теперь езжайте по стрелкам вокруг конусов в сторону эстакады.")
        NextStepCar = 5
    elseif math.sqrt( (ax - ux) ^ 5 + (ay - uy) ^ 5 + (az - uz) ^ 5 ) < 10 and NextStepCar == 5 then -- 5 - радиус срабатывания\
    wait(1000)
        sampSendChat("Подъезжайте к эстакаде и остановитесь перед линией.")
        NextStepCar = 6
    elseif math.sqrt( (ax - ox) ^ 5 + (ay - oy) ^ 5 + (az - oz) ^ 5 ) < 10 and NextStepCar == 6 then -- 5 - радиус срабатывания\
    wait(1000)
        sampSendChat("Теперь осторожно проезжайте по мосту, затем возле надписи стоп остановитесь.")
        NextStepCar = 7
    elseif math.sqrt( (ax - px) ^ 5 + (ay - py) ^ 5 + (az - pz) ^ 5 ) < 10 and NextStepCar == 7 then -- 5 - радиус срабатывания\
    wait(1000)
    sampSendChat("Отлично, теперь поставьте автомобиль на парковку!")
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
    if math.sqrt( (ax - bx) ^ 5 + (ay - by) ^ 5 + (az - bz) ^ 5 ) < 10 and NextStepMoto == 1 then -- 5 - радиус срабатывания
    wait(1000)
        sampSendChat('Соблюдайте указания стрелок на асфальте и объезжайте конусы змейкой.')
        NextStepMoto = 2
    elseif math.sqrt( (ax - ex) ^ 5 + (ay - ey) ^ 5 + (az - ez) ^ 5 ) < 10 and NextStepMoto == 2 then -- 5 - радиус срабатывания
    wait(1000)
        sampSendChat('Следуя по маршруту, двигайтесь в сторону эстакады.')
        NextStepMoto = 3
    elseif math.sqrt( (ax - qx) ^ 5 + (ay - qy) ^ 5 + (az - qz) ^ 5 ) < 10 and NextStepMoto == 3 then -- 5 - радиус срабатывания\
    wait(1000)
        sampSendChat('Теперь осторожно проедьтесь по эстакаде.')
        NextStepMoto = 4
    elseif math.sqrt( (ax - wx) ^ 5 + (ay - wy) ^ 5 + (az - wz) ^ 5 ) < 10 and NextStepMoto == 4 then -- 5 - радиус срабатывания\
    wait(1000)
        sampSendChat('Следуя стрелкам, сделайте восмерьку вокруг дерева')
        NextStepMoto = 5
    elseif math.sqrt( (ax - ux) ^ 5 + (ay - uy) ^ 5 + (az - uz) ^ 5 ) < 10 and NextStepMoto == 5 then -- 5 - радиус срабатывания\
    wait(1000)
        sampSendChat('А теперь припаркуйте мотоцикл в обозначенную область.')
        NextStepMoto = 6
    elseif math.sqrt( (ax - ox) ^ 2 + (ay - oy) ^ 2 + (az - oz) ^ 2 ) < 5 and NextStepMoto == 6 then -- 5 - радиус срабатывания\
    wait(1000)
        sampSendChat('Припарковав мотоцикл, езжайте по дальнейшому маршруту.')
        NextStepMoto = 7
    elseif math.sqrt( (ax - px) ^ 3 + (ay - py) ^ 3 + (az - pz) ^ 3 ) < 6 and NextStepMoto == 7 then -- 5 - радиус срабатывания\
    wait(1000)
        sampSendChat('Преодолейте препятствие, проехав между конусами.')
        NextStepMoto = 8
    elseif math.sqrt( (ax - cx) ^ 5 + (ay - cy) ^ 5 + (az - cz) ^ 5 ) < 10 and NextStepMoto == 8 then -- 5 - радиус срабатывания\
    wait(1000)
        sampSendChat('Преодолейте искусственные неровности')
        NextStepMoto = 9
    elseif math.sqrt( (ax - sx) ^ 5 + (ay - sy) ^ 5 + (az - sz) ^ 5 ) < 10 and NextStepMoto == 9 then -- 5 - радиус срабатывания\
    wait(1000)
        sampSendChat('Под конец пройдите конусы змейкой на нормальной скорости.')
        NextStepMoto = 10
    elseif math.sqrt( (ax - vx) ^ 5 + (ay - vy) ^ 5 + (az - vz) ^ 5 ) < 10 and NextStepMoto == 10 then -- 5 - радиус срабатывания\
    wait(1000)
        sampSendChat('Теперь припаркуйте мотоцикл в том месте, где его взяли.')
    NextStepMoto = 0
    RunMotoExam = false
    MotoExamResume = true
    end
end

if RunBigCarExam then
    local ax, ay, az = getCharCoordinates(1)  
    local bx, by, bz = -2130, -85, 35 -- 1
    --local ex, ey, ez = -2087, -68, 35 -- 2
    if math.sqrt( (ax - bx) ^ 5 + (ay - by) ^ 5 + (az - bz) ^ 5 ) < 10 and NextStepBigCar == 1 then -- 5 - радиус срабатывания
    wait(1000)
        sampSendChat('Поверните налево, после чего сделайте круг вокруг Лицензионного центра')
        wait(2000)
        sampSendChat('Поворачивайте на поворотах только налево.')
        --NextStepBigCar = 2
    --elseif math.sqrt( (ax - ex) ^ 5 + (ay - ey) ^ 5 + (az - ez) ^ 5 ) < 10 and NextStepBigCar == 2 then -- 5 - радиус срабатывания
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
    sampSendChat('Здравствуйте, я '..myrang..', '..rpnick..', чем могу быть полезен?')
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
            if imgui.Button(u8'Лекции', imgui.ImVec2(Xbm, Ybm)) then Child['Lekcii'] = not Child['Lekcii'] Child['Settings'] = false Child['Leader'] = false Child['InterviewM'] = false Child['Support'] = false end
            if imgui.Button(u8'Рук. составу', imgui.ImVec2(Xbm, Ybm)) then Child['Leader'] = not Child['Leader'] Child['Lekcii'] = false Child['Settings'] = false Child['InterviewM'] = false Child['Support'] = false end
            if imgui.Button(u8'Настройки', imgui.ImVec2(Xbm, Ybm)) then Child['Settings'] = not Child['Settings'] Child['Lekcii'] = false Child['Leader'] = false Child['InterviewM'] = false Child['Support'] = false end
            if imgui.Button(u8'Собесед-ние', imgui.ImVec2(Xbm, Ybm)) then Child['InterviewM'] = not Child['InterviewM'] Child['Lekcii'] = false Child['Leader'] = false Child['Settings'] = false Child['Support'] = false end
            imgui.SetCursorPosY(242)
            if imgui.Button(u8'О скрипте', imgui.ImVec2(Xbm, Ybm)) then Child['Support'] = not Child['Support'] Child['Lekcii'] = false Child['Leader'] = false Child['Settings'] = false Child['InterviewM'] = false end
        imgui.EndChild()
        imgui.SameLine()

            imgui.SetCursorPosX(110)
            imgui.BeginChild('Settings', imgui.ImVec2(255,275), true)
            if Child['Settings'] then
                local XposEl, XposBinds = 120, 145
                imgui.SetCursorPosY(10)
                imgui.Text(u8'Ваша должность:') imgui.SameLine()
                imgui.PushItemWidth(125) imgui.SetCursorPos(imgui.ImVec2(XposEl,9))
                if imgui.Combo('##ASRang', ASRang, arr_rang, #arr_rang)  then
                    main_ini.config.ASRang = ASRang.v
                    inicfg.save(main_ini, main_iniPath)
                end
                imgui.Text(u8'Тег в рацию:') imgui.SameLine()
                if imgui.ToggleButton(u8'tagF', Toggle['TagF']) then main_ini.config.TagF = Toggle['TagF'].v inicfg.save(main_ini, main_iniPath) end 
                imgui.SameLine() imgui.SetCursorPosX(XposEl)
                if imgui.InputText('##InputTag', Input['Tag']) then
                    main_ini.config.Tag = Input['Tag'].v 
                    inicfg.save(main_ini, main_iniPath)
                end
                imgui.Text(u8'Ваш пол:') imgui.SameLine() imgui.SetCursorPosX(130)
                if imgui.RadioButton(u8'Муж', Radio['Gender'], 1) then main_ini.config.Gender = Radio['Gender'].v inicfg.save(main_ini, main_iniPath) end
                imgui.SameLine()
                if imgui.RadioButton(u8'Жен', Radio['Gender'], 2) then main_ini.config.Gender = Radio['Gender'].v inicfg.save(main_ini, main_iniPath) end
                imgui.Text(u8'Авто-скрин:') imgui.SameLine()
                if imgui.ToggleButton('', Toggle['AutoScreen']) then main_ini.config.AutoScreen = Toggle['AutoScreen'].v inicfg.save(main_ini, main_iniPath) end
                imgui.SameLine()
                imgui.TextQuestion(u8'При включенном авто-скрине, скринятся:\nСдача успешных экзаменов, продажа лицензий, страховка авто, зачитывание лецкий.')
                imgui.Separator() imgui.SetCursorPosX(70) imgui.Text(u8"Настройка клавиш") imgui.Separator()
                imgui.Text(u8"Диалоговое окно")
                imgui.SameLine() imgui.SetCursorPosX(XposBinds)
                if imgui.HotKey("##1", ActiveMainMenu, tLastKeys, 100) then
                    rkeys.changeHotKey(bindMainMenu, ActiveMainMenu.v)
                    --sampAddChatMessage("Успешно! Старое значение: {F4A460}" .. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. "{ffffff} | Новое: {F4A460}" .. table.concat(rkeys.getKeysName(ActiveMainMenu.v), " + "), -1)
                    --sampAddChatMessage("Строчное значение: {F4A460}" .. encodeJson(ActiveMainMenu.v), -1)
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
                imgui.Text(u8"Приветствие")
                imgui.SameLine() imgui.SetCursorPosX(XposBinds)
                if imgui.HotKey("##4", ActiveHello, tLastKeys, 100) then
                    rkeys.changeHotKey(bindHello, ActiveHello.v)
                    main_ini.hotkeys.Hello = encodeJson(ActiveHello.v)
                    inicfg.save(main_ini, main_iniPath)
                end
                imgui.Text(u8"Рация")
                imgui.SameLine() imgui.SetCursorPosX(XposBinds)
                if imgui.HotKey("##5", ActiveR, tLastKeys, 100) then
                    rkeys.changeHotKey(bindR, ActiveR.v)
                    main_ini.hotkeys.R = encodeJson(ActiveR.v)
                    inicfg.save(main_ini, main_iniPath)
                end
                imgui.Text(u8"нРП Рация")
                imgui.SameLine() imgui.SetCursorPosX(XposBinds)
                if imgui.HotKey("##6", ActiveRN, tLastKeys, 100) then
                    rkeys.changeHotKey(bindRN, ActiveRN.v)
                    main_ini.hotkeys.RN = encodeJson(ActiveRN.v)
                    inicfg.save(main_ini, main_iniPath)
                end
            elseif Child['Lekcii'] then
                local Xbl, Ybl = 240, 25
                if imgui.Button(u8'Транспорт в Лицензионном Центре', imgui.ImVec2(Xbl, Ybl)) then vehicleLC() end
                if imgui.Button(u8'Этикет и Субординация', imgui.ImVec2(Xbl, Ybl)) then EticetSub() end
                if imgui.Button(u8'Правила использования Рации', imgui.ImVec2(Xbl, Ybl)) then RulesUseR() end
                if imgui.Button(u8'Основные правила и обязанности ЛЦ', imgui.ImVec2(Xbl, Ybl)) then GeneralRules() end
                if imgui.Button(u8'Правила использования Доски', imgui.ImVec2(Xbl, Ybl)) then RulesUseDesk() end imgui.Text('')
                if imgui.ToggleButton(u8'Лекции в /f', Toggle['LecF']) then main_ini.config.LecF = Toggle['LecF'].v inicfg.save(main_ini, main_iniPath) end
                imgui.SameLine()
                imgui.TextQuestion(u8'Если включено, будет читать лекции в рацию\nЕсли выключено, будет читать лекции в чат')
            elseif Child['Leader'] then
                local Xbl2, Ybl2 = 240, 25
                if imgui.Button(u8'Повышение', imgui.ImVec2(Xbl2, Ybl2)) then rangup(2) end
                if imgui.Button(u8'Выдать скин', imgui.ImVec2(Xbl2, Ybl2)) then giveskin(2) end
                if imgui.Button(u8'Выговор', imgui.ImVec2(Xbl2, Ybl2)) then givewarn(2) end
                if imgui.Button(u8'Выговор в оффлайне', imgui.ImVec2(Xbl2, Ybl2)) then givewarnoff(2) end
                if imgui.Button(u8'Снятие выговора', imgui.ImVec2(Xbl2, Ybl2)) then takeoffwarn(2) end
                if imgui.Button(u8'Увольнение', imgui.ImVec2(Xbl2, Ybl2)) then uninvite(2) end
                if imgui.Button(u8'Увольнение в оффлайне', imgui.ImVec2(Xbl2, Ybl2)) then uninviteoff(2) end
                if imgui.Button(u8'Занесение в ЧС', imgui.ImVec2(Xbl2, Ybl2)) then gobl(2) end
                if imgui.Button(u8'Занесение в ЧС в оффлайне', imgui.ImVec2(Xbl2, Ybl2)) then gobloff(2) end
                if imgui.Button(u8'Вынесение из ЧС', imgui.ImVec2(Xbl2, Ybl2)) then backbl(2) end
                if imgui.Button(u8'Принять человека (/invite)', imgui.ImVec2(Xbl2, Ybl2)) then inviteFunc(2) end
            elseif Child['InterviewM'] then
                local Xbi2, Ybi2 = 240, 23
                local Xbi3, Ybi3 = 116, 23
                if imgui.Button(u8'Привет (1)', imgui.ImVec2(Xbi2-165, Ybi2+5)) then 
                    lua_thread.create(function()
                        sampSendChat("Здравствуйте, вы на собеседование?")
                        wait(200)
                        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • После ответа нажмите - {58ACFA}1{FFFFFF}. Отмена - {58ACFA}2{FFFFFF}.', -1)
                        repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
                        if isKeyJustPressed(0x31) then
                            sampSendChat('Хорошо, покажите Ваш паспорт, лицензии и медицинскую карту.')
                            wait(2000)
                            sampSendChat('/n Показать паспорт - /pass '..myid..' , мед. карту - /med '..myid..', лицензии - /lic '..myid..'.')
                        elseif isKeyJustPressed(0x32) then
                        end
                    end)
                end imgui.SameLine()
                if imgui.Button(u8'Почему вы? (4)', imgui.ImVec2(Xbi2-145, Ybi2+5)) then 
                    lua_thread.create(function()
                        sampSendChat('Хорошо, назовите два своих главных качества')
                        wait(2000)
                        sampSendChat('И почему вы хотите работать именно у нас?')
                    end)
                end imgui.SameLine()
                if imgui.Button(u8'Принять', imgui.ImVec2(Xbi2-185, Ybi2+5)) then 
                    inviteFunc(1)
                end
                imgui.Separator()
                imgui.TextRGB('    РП термины (2)') imgui.SameLine() imgui.TextRGB('Действия (3)      ', 3)
                --imgui.Separator()
                    if imgui.Button(u8'Что над головой?', imgui.ImVec2(Xbi3, Ybi3)) then 
                        sampSendChat('Хорошо, что у меня над головой?')
                    end imgui.SameLine()
                    if imgui.Button(u8'Сядьте (IC)', imgui.ImVec2(Xbi3, Ybi3)) then 
                        sampSendChat('Сядьте.')
                    end
                    if imgui.Button(u8'Что такое РП?', imgui.ImVec2(Xbi3, Ybi3)) then 
                        sampSendChat('Хорошо, что такое РП?')
                    end imgui.SameLine()
                    if imgui.Button(u8'Встаньте (OOC)', imgui.ImVec2(Xbi3, Ybi3)) then 
                        sampSendChat('/n Вставайте.')
                    end
                    if imgui.Button(u8'Что такое СК?', imgui.ImVec2(Xbi3, Ybi3)) then 
                        sampSendChat('Хорошо, что такое СК?')
                    end imgui.SameLine()
                    if imgui.Button(u8'Встаньте (IC)', imgui.ImVec2(Xbi3, Ybi3)) then 
                        sampSendChat('Вставайте.')
                    end
                imgui.Separator()
                    imgui.TextRGB('Отказ по причине') imgui.SameLine()
                    imgui.SetCursorPosX(155)
                    imgui.Text(u8'Критерии '..fa.ICON_LONG_ARROW_RIGHT) imgui.SameLine()
                    imgui.TextQuestion(u8'Быть законопослушным. (( Законопослушность 15+ ))\nПроживать в республике 3 года (( Иметь 3 LvL ))\nИметь пройденный медицинский осмотр.')
                    if imgui.Button(u8'Недостаточно законопослушности', imgui.ImVec2(Xbi2, Ybi2)) then 
                        lua_thread.create(function()
                            sampSendChat('Извините, но вы незаконопослушный. Отказано.')
                            wait(1500)
                            sampSendChat('/n Необходимо 15+ законопослушности.')
                        end)
                    end
                    if imgui.Button(u8'НонРП ник', imgui.ImVec2(Xbi2, Ybi2)) then 
                        lua_thread.create(function()
                            sampSendChat('У вас опечатка в паспорте, вы не приняты.')
                            wait(2000)
                            sampSendChat('/n Введите /mn - Смена НонРП Ника.')
                        end)
                    end
                    if imgui.Button(u8'Нет 18 лет', imgui.ImVec2(Xbi2, Ybi2)) then 
                        sampSendChat('Вам нет 18 лет, вы не приняты.')
                    end
                    if imgui.Button(u8'Простой отказ', imgui.ImVec2(Xbi2, Ybi2)) then 
                        sampSendChat('Извините, вы нам не подходите.')
                    end
            elseif Child['Support'] then
                imgui.TextRGB('Автор скрипта - {FFFF00}Banana Blackstone', 2)
                imgui.TextRGB('Спасибо за помощь - {FF8000}Lance Connors', 2)
                imgui.Text('')
                imgui.TextRGB('Севрер {01DF01}Emerald', 2)

                imgui.SetCursorPos(imgui.ImVec2(58, 160))
                if imgui.Button(u8'Обновить скрипт', imgui.ImVec2(140, 25)) then
                    if update_state then
                        downloadUrlToFile(script_url, script_path, function(id, status)
                            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                                sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Скрипт {58ACFA}успешно {FFFFFF}обновлен', -1)
                                thisScript():reload()
                            end
                        end)
                    else
                        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • У Вас {58ACFA}последняя версия{FFFFFF} скрипта', -1)
                    end
                end imgui.SetCursorPosX(58)
                if imgui.Button(u8'Последнии изменения', imgui.ImVec2(140, 25)) then latest_update() end imgui.SetCursorPosY(250)
                imgui.TextRGB('Версия скрипта - '..updateini.script.version_text, 3)
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

        imgui.Begin(u8'Действия с '..targNick..'['..tid..']##2', Window['Target'], imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        local Xbm, Ybm = 123, 25 --X 120
        imgui.SetCursorPosY(25)
        if imgui.Button(u8'Экзамен', imgui.ImVec2(Xbm, Ybm)) then Child['Exam'] = not Child['Exam'] Child['Work'] = false end
        imgui.SameLine()
        if imgui.Button(u8'Сотрудник', imgui.ImVec2(Xbm, Ybm)) then Child['Work'] = not Child['Work'] Child['Exam'] = false end

            imgui.SetCursorPosY(55)
            imgui.BeginChild('Settings2', imgui.ImVec2(255,275), true)
            if Child['Exam'] then
                imgui.Text(u8'Выберите действие:') imgui.Separator()
                local Xsb, Ysb = 240, 25
                if imgui.Button(u8'Наземный транспорт', imgui.ImVec2(Xsb,Ysb)) then
                    carExam()
                end
                if imgui.Button(u8'Воздушный транспорт', imgui.ImVec2(Xsb,Ysb)) then
                    airExam()
                end
                if imgui.Button(u8'Мототранспорт', imgui.ImVec2(Xsb,Ysb)) then
                    motoExam()
                end
                if imgui.Button(u8'Грузовой экзамен', imgui.ImVec2(Xsb,Ysb)) then
                    bigcarExam()
                end
                imgui.Text('') imgui.Separator()
                if imgui.Button(u8'Лицензия на оружие', imgui.ImVec2(Xsb,Ysb)) then
                    SellLic(2)
                end
                if imgui.Button(u8'Лицензия на водный транспорт', imgui.ImVec2(Xsb,Ysb)) then
                    SellLic(1)
                end
                if imgui.Button(u8'Страховка', imgui.ImVec2(Xsb,Ysb)) then
                    sellinsurance()
                end
            elseif Child['Work'] then
                local Xbl2, Ybl2 = 240, 25
                if imgui.Button(u8'Повышение', imgui.ImVec2(Xbl2, Ybl2)) then rangup(1) end
                if imgui.Button(u8'Выдать скин', imgui.ImVec2(Xbl2, Ybl2)) then giveskin(1) end
                if imgui.Button(u8'Выговор', imgui.ImVec2(Xbl2, Ybl2)) then givewarn(1) end
                if imgui.Button(u8'Снятие выговора', imgui.ImVec2(Xbl2, Ybl2)) then takeoffwarn(1) end
                if imgui.Button(u8'Увольнение', imgui.ImVec2(Xbl2, Ybl2)) then uninvite(1) end
                if imgui.Button(u8'Занесение в ЧС', imgui.ImVec2(Xbl2, Ybl2)) then gobl(1) end
                if imgui.Button(u8'Вынесение из ЧС', imgui.ImVec2(Xbl2, Ybl2)) then backbl(1) end
                if imgui.Button(u8'Принять человека (/invite)', imgui.ImVec2(Xbl2, Ybl2)) then inviteFunc(3) end
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
        sampSendChat('Здравствуйте, я сотрудник Автошколы '..rpnick..' и я буду проводить у Вас экзамен.')
        wait(2100)
        sampSendChat('Предъявите Ваш паспорт.')
        wait(2100)
        sampSendChat('/n Введите команду: /pass '..myid)
        wait(200)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Критерии: {58ACFA}18+ лет{FFFFFF}.', -1) wait(1)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Для продолжения нажмите - {58ACFA}1{FFFFFF}. Если не допущен, то нажмите - {58ACFA}2{FFFFFF}. Отмена - {58ACFA}3{FFFFFF}.', -1)
        repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
        if isKeyJustPressed(0x31) then
            sampSendChat('/me достал'..Sex..' ручку и талон из кармана штанов')
            wait(2100)
            sampSendChat('/me вписал'..Sex..' имя и фамилию экзаменуемого, после чего передал'..Sex..' талон ему')
            wait(2100)
            sampSendChat('Пройдёмте за мной для сдачи практической части экзамена.')
            wait(2100)
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Начал'..Sex..' проводить экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Наземный транспорт')
            else
                sampSendChat('/f Начал'..Sex..' проводить экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Наземный транспорт')
            end
            wait(200)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Для продолжения нажмите - {58ACFA}1{FFFFFF}. Отмена - {58ACFA}2{FFFFFF}.', -1)
                repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
                if isKeyJustPressed(0x31) then
                    sampSendChat('Присаживайтесь на место водителя и ожидайте моих дальнейших указаний.')
                    wait(2100)
                    sampSendChat('Для начала пристегните ремень безопасности.')
                    wait(2100)
                    sampSendChat('/n /me пристегнул(а) ремень безопасности')
                    wait(2100)
                    sampSendChat('/me пристегнул'..Sex..' ремень безопасности')
                    wait(2100)
                    sampSendChat('Заводите двигатель, включайте фары и двигайтесь к метке "Старт".')
                    wait(2100)
                    sampSendChat('/n Завести двигатель можно нажав на клавишу [Ctrl], включить фары [Alt].')
                    RunCarExam = true
                    NextStepCar = 1
                    while not CarExamResume do
                        wait(0)
                        if CarExamResume then
                            wait(1500)
                            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • После того как припарковались, нажмите:', -1)
                            wait(1)
                            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Сдал - {58ACFA}1{FFFFFF}, Не сдал - {58ACFA}2{FFFFFF}, Отмена - {58ACFA}3{FFFFFF}.', -1)
                            repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
                            if isKeyJustPressed(0x31) then
                                sampSendChat('/me приоткрыл'..Sex..' кейс, после чего достал'..Sex..' бумаги и начал'..Sex..' заполнять их')
                                wait(2100)
                                sampSendChat('/me вписал'..Sex..' имя и фамилию клиента')
                                wait(2100)
                                sampSendChat('/me достал'..Sex..' правой рукой водительское удостоверение, после чего передал'..Sex..' клиенту')
                                wait(2100)
                                sampSendChat('/me после заполнения документов, аккуратно сложил'..Sex..' их и закрыл'..Sex..' кейс')
                                wait(2100)
                                if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                                    sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Завершил'..Sex..' экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Наземный транспорт || Результат: Успешно.')
                                else
                                    sampSendChat('/f Завершил'..Sex..' экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Наземный транспорт || Результат: Успешно.')
                                end
                                ExamEnd(1)
                                wait(2100)
                                sampSendChat('/exam')
                                if Toggle['AutoScreen'].v then TimeScreen() end
                                CarExamResume = false
                                congr()
                            elseif isKeyJustPressed(0x32) then
                                sampSendChat('Вы допустили слишком много ошибок, отправляйтесь на пересдачу.')
                                wait(2100)
                                if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                                    sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Завершил'..Sex..' экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Наземный транспорт || Результат: Не удачно.')
                                else
                                    sampSendChat('/f Завершил'..Sex..' экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Наземный транспорт || Результат: Не удачно.')
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
            sampSendChat('У Вас проблемы с документами, я не могу принять у Вас экзамен.')
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
        sampSendChat('Здравствуйте, я сотрудник Автошколы, '..rpnick..' и я буду проводить у Вас экзамен.')
        wait(2100)
        sampSendChat('Предъявите Ваш паспорт и медицинскую карту.')
        wait(2100)
        sampSendChat('/n Введите команду: /pass '..myid..', мед. карта: /med '..myid)
        wait(200)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Критерии: {58ACFA}18+ лет{FFFFFF} • Пройденый мед. осмотр • {58ACFA}2 LvL{FFFFFF}', -1) wait(1)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Для продолжения нажмите - {58ACFA}1{FFFFFF}. Если не допущен, то нажмите - {58ACFA}2{FFFFFF}. Отмена - {58ACFA}3{FFFFFF}.', -1)
        repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
        if isKeyJustPressed(0x31) then
            sampSendChat('/me достал'..Sex..' ручку и талон из кармана брюк')
            wait(2100)
            sampSendChat('/me вписал'..Sex..' имя и фамилию экзаменуемого, после чего передал'..Sex..' ему')
            wait(2100)
            sampSendChat('Пройдёмте за мной для сдачи практической части экзамена.')
            wait(2100)
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Начал'..Sex..' проводить экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Воздушный транспорт')
            else
                sampSendChat('/f Начал'..Sex..' проводить экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Воздушный транспорт') 
            end
            wait(200)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Для продолжения нажмите - {58ACFA}1{FFFFFF}. Отмена - {58ACFA}2{FFFFFF}.', -1)
                repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
                if isKeyJustPressed(0x31) then
                    sampSendChat('Садитесь на место пилота, после чего ждите моих указаний.')
                    wait(2100)
                    sampSendChat('Для начала наденьте наушники, пристегните ремень безопасности.')
                    wait(2100)
                    sampSendChat('/n /me надел(а) наушники и пристегнул(а) ремень безопасности')
                    wait(2100)
                    sampSendChat('/me надел'..Sex..' наушники и пристегнул'..Sex..' ремень безопасности')
                    wait(2100)
                    sampSendChat('Можете заводить двигатель и взлетать, делаем круг на территории Автошколы.')
                    wait(2100)
                    sampSendChat('После того, как сделаете круг - приземляйтесь в то место, откуда взяли вертолёт.')
                    wait(1500)
                    sampAddChatMessage('{58ACFA}ASA{FFFFFF} • После того как приземлились, нажмите:', -1)
                    wait(1)
                    sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Сдал - {58ACFA}1{FFFFFF}, Не сдал - {58ACFA}2{FFFFFF}, Отмена - {58ACFA}3{FFFFFF}.', -1)
                    repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
                    if isKeyJustPressed(0x31) then
                        sampSendChat('/me приоткрыл'..Sex..' кейс, после чего достал'..Sex..' бумаги и начал'..Sex..' заполнять их')
                        wait(2100)
                        sampSendChat('/me вписал'..Sex..' имя и фамилию клиента')
                        wait(2100)
                        sampSendChat('/me достал'..Sex..' правой рукой водительское удостоверение, после чего передал'..Sex..' клиенту')
                        wait(2100)
                        sampSendChat('/me после заполнения документов, аккуратно сложил'..Sex..' их и закрыл'..Sex..' кейс')
                        wait(2100)
                        if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                            sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Завершил'..Sex..' экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Воздушный транспорт || Результат: Успешно.')
                        else
                            sampSendChat('/f Завершил'..Sex..' экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Воздушный транспорт || Результат: Успешно.') 
                        end
                        ExamEnd(1)
                        wait(2100)
                        sampSendChat('/exam')
                        if Toggle['AutoScreen'].v then TimeScreen() end
                        congr()
                    elseif isKeyJustPressed(0x32) then
                        sampSendChat('Вы допустили слишком много ошибок, отправляйтесь на пересдачу.')
                        wait(2100)
                        if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                            sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Завершил'..Sex..' экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Воздушный транспорт || Результат: Не удачно.')
                        else
                            sampSendChat('/f Завершил'..Sex..' экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Воздушный транспорт || Результат: Не удачно.') 
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
            sampSendChat('У Вас проблемы с документами, я не могу принять у Вас экзамен.')
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
        sampSendChat('Здравствуйте, я сотрудник Автошколы '..rpnick..' и я буду проводить экзамен.')
        wait(2100)
        sampSendChat('Предъявите Ваш паспорт и мед.карту')
        wait(2100)
        sampSendChat('/n Введите команду: /pass '..myid..', мед. карта: /med '..myid)
        wait(200)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Критерии: {58ACFA}18+ лет{FFFFFF} • Пройденый мед. осмотр • {58ACFA}2 LvL{FFFFFF}', -1) wait(1)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Для продолжения нажмите - {58ACFA}1{FFFFFF}. Если не допущен, то нажмите - {58ACFA}2{FFFFFF}. Отмена - {58ACFA}3{FFFFFF}.', -1)
        repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
        if isKeyJustPressed(0x31) then
            sampSendChat('/me достал'..Sex..' ручку и талон из кармана брюк')
            wait(2100)
            sampSendChat('/me вписал'..Sex..' имя и фамилию экзаменуемого, после чего передал'..Sex..' ему')
            wait(2100)
            sampSendChat('Пройдёмте за мной для сдачи практической части экзамена.')
            wait(2100)
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Начал'..Sex..' проводить экзамен с клиентом №'..tid..' '..targrpnick..' | Категория: Мототранспорт')
            else
                sampSendChat('/f Начал'..Sex..' проводить экзамен с клиентом №'..tid..' '..targrpnick..' | Категория: Мототранспорт')  
            end
            wait(200)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Для продолжения нажмите - {58ACFA}1{FFFFFF}. Отмена - {58ACFA}2{FFFFFF}.', -1)
                repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
                if isKeyJustPressed(0x31) then
                    sampSendChat('Садитесь на мотоцикл, после чего ожидайте дальнейших указаний.')
                    wait(2100)
                    sampSendChat('Для начала наденьте шлем.')
                    wait(2100)
                    sampSendChat('/n /me взял(а) шлем с мотоцикла, после чего надел(а) его')
                    wait(2100)
                    sampSendChat('/me взял'..Sex..' шлем с мотоцикла, после чего надел'..Sex..' его')
                    wait(2100)
                    sampSendChat('Заводите двигатель, включайте фары и двигайтесь к метке "Старт".')
                    wait(2100)
                    sampSendChat('/n Завести двигатель можно нажав на клавишу [Ctrl], включить фары [Alt].')
                    RunMotoExam = true
                    NextStepMoto = 1
                    while not MotoExamResume do
                        wait(0)
                        if MotoExamResume then
                            wait(1500)
                            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • После того как припарковались, нажмите:', -1)
                            wait(1)
                            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Сдал - {58ACFA}1{FFFFFF}, Не сдал - {58ACFA}2{FFFFFF}, Отмена - {58ACFA}3{FFFFFF}.', -1)
                            repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
                            if isKeyJustPressed(0x31) then
                                sampSendChat('/me приоткрыл'..Sex..' кейс, после чего достал'..Sex..' бумаги и начал'..Sex..' заполнять их')
                                wait(2100)
                                sampSendChat('/me вписал'..Sex..' имя и фамилию клиента')
                                wait(2100)
                                sampSendChat('/me достал'..Sex..' правой рукой водительское удостоверение, после чего передал'..Sex..' клиенту')
                                wait(2100)
                                sampSendChat('/me после заполнения документов, аккуратно сложил'..Sex..' их и закрыл'..Sex..' кейс')
                                wait(2100)
                                if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                                    sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Завершил'..Sex..' экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Мототранспорт  || Результат: Успешно.')
                                else
                                    sampSendChat('/f Завершил'..Sex..' экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Мототранспорт  || Результат: Успешно.') 
                                end
                                ExamEnd(1)
                                wait(2100)
                                sampSendChat('/exam')
                                if Toggle['AutoScreen'].v then TimeScreen() end
                                MotoExamResume = false
                                congr()
                            elseif isKeyJustPressed(0x32) then
                                sampSendChat('Вы допустили слишком много ошибок, отправляйтесь на пересдачу.')
                                wait(2100)
                                if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                                    sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Завершил'..Sex..' экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Мототранспорт  || Результат: Не удачно.')
                                else
                                    sampSendChat('/f Завершил'..Sex..' экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Мототранспорт  || Результат: Не удачно.') 
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
            sampSendChat('У Вас проблемы с документами, я не могу принять у Вас экзамен.')
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
        sampSendChat('Здравствуйте, я сотрудник Автошколы '..rpnick..' и я буду проводить экзамен.')
        wait(2100)
        sampSendChat('Предъявите Ваш паспорт и мед.карту')
        wait(2100)
        sampSendChat('/n Введите команду: /pass '..myid..', мед. карта: /med '..myid)
        wait(200)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Критерии: {58ACFA}18+ лет{FFFFFF} • Пройденый мед. осмотр • {58ACFA}4 LvL{FFFFFF}', -1) wait(1)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Для продолжения нажмите - {58ACFA}1{FFFFFF}. Если не допущен, то нажмите - {58ACFA}2{FFFFFF}. Отмена - {58ACFA}3{FFFFFF}.', -1)
        repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
        if isKeyJustPressed(0x31) then
            sampSendChat('/me достал'..Sex..' ручку и талон из кармана брюк')
            wait(2100)
            sampSendChat('/me вписал'..Sex..' имя и фамилию экзаменуемого, после чего передал'..Sex..' ему')
            wait(2100)
            sampSendChat('Пройдёмте за мной для сдачи практической части экзамена.')
            wait(2100)
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Начал'..Sex..' проводить экзамен с клиентом №'..tid..' '..targrpnick..' | Категория: Грузовой т/c.')
            else
                sampSendChat('/f Начал'..Sex..' проводить экзамен с клиентом №'..tid..' '..targrpnick..' | Категория: Грузовой т/c.') 
            end
            wait(200)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Для продолжения нажмите - {58ACFA}1{FFFFFF}. Отмена - {58ACFA}2{FFFFFF}.', -1)
                repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
                if isKeyJustPressed(0x31) then
                    sampSendChat('Присаживайтесь на место водителя и ожидайте моих дальнейших указаний.')
                    wait(2100)
                    sampSendChat('Для начала пристегните ремень безопасности.')
                    wait(2100)
                    sampSendChat('/n /me пристегнул(а) ремень безопасности')
                    wait(2100)
                    sampSendChat('/me пристегнул'..Sex..' ремень безопасности')
                    wait(2100)
                    sampSendChat('Заводите двигатель, выезжайте на проезжую часть и ожидайте дальнейших указаний.')
                    wait(2100)
                    sampSendChat('/n Завести двигатель можно нажав на клавишу [Ctrl], включить фары [Alt].')
                    RunBigCarExam = true
                    NextStepBigCar = 1
                    while not BigCarExamResume do
                        wait(0)
                        if BigCarExamResume then
                            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • После окончания круга нажмите - {58ACFA}1{FFFFFF}. Отмена - {58ACFA}2{FFFFFF}.', -1)
                            repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
                            if isKeyJustPressed(0x31) then
                                sampSendChat('Теперь припаркуйте фуру на место, откуда ее взяли.')
                                wait(1500)
                                sampAddChatMessage('{58ACFA}ASA{FFFFFF} • После того как припарковались, нажмите:', -1)
                                wait(1)
                                sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Сдал - {58ACFA}1{FFFFFF}, Не сдал - {58ACFA}2{FFFFFF}, Отмена - {58ACFA}3{FFFFFF}.', -1)
                                repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
                                if isKeyJustPressed(0x31) then
                                    sampSendChat('/me приоткрыл'..Sex..' кейс, после чего достал'..Sex..' бумаги и начал'..Sex..' заполнять их')
                                    wait(2100)
                                    sampSendChat('/me вписал'..Sex..' имя и фамилию клиента')
                                    wait(2100)
                                    sampSendChat('/me достал'..Sex..' правой рукой водительское удостоверение, после чего передал'..Sex..' клиенту')
                                    wait(2100)
                                    sampSendChat('/me после заполнения документов, аккуратно сложил'..Sex..' их и закрыл'..Sex..' кейс')
                                    wait(2100)
                                    if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                                        sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Завершил'..Sex..' экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Грузовой т/c || Результат: Успешно.')
                                    else
                                        sampSendChat('/f Завершил'..Sex..' экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Грузовой т/c || Результат: Успешно.') 
                                    end
                                    ExamEnd(1)
                                    wait(2100)
                                    sampSendChat('/exam')
                                    if Toggle['AutoScreen'].v then TimeScreen() end
                                    BigCarExamResume = false
                                    congr()
                                elseif isKeyJustPressed(0x32) then
                                    sampSendChat('Вы допустили слишком много ошибок, отправляйтесь на пересдачу.')
                                    wait(2100)
                                    if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                                        sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Завершил'..Sex..' экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Грузовой т/c || Результат: Не удачно.')
                                    else
                                        sampSendChat('/f Завершил'..Sex..' экзамен с клиентом №'..tid..' '..targrpnick..' || Категория: Грузовой т/c || Результат: Не удачно.') 
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
            sampSendChat('У Вас проблемы с документами, я не могу принять у Вас экзамен.')
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
        sampSendChat('Здравствуйте, меня зовут '..rpnick..', я продавец лицензий.')
        wait(2100)
        sampSendChat('Какую лицензию желаете приобрести? На водный транспорт или на оружие?')
        wait(2100)
        sampSendChat('Стоимость лицензии на водный транспорт - 20.000$, а на оружие - 30.000$.')
        wait(1500)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Для продолжения нажмите - {58ACFA}1{FFFFFF}. Отмена - {58ACFA}2{FFFFFF}.', -1)
            repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
            if isKeyJustPressed(0x31) then
                sampSendChat('Хорошо, предъявите мне Ваш паспорт и мед. карту.')
                wait(1500)
                sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Критерии: {58ACFA}18+ лет{FFFFFF} • Пройденый мед. осмотр', -1) wait(1)
                sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Для продолжения нажмите - {58ACFA}1{FFFFFF}. Если не допущен, то нажмите - {58ACFA}2{FFFFFF}. Отмена - {58ACFA}3{FFFFFF}.', -1)
                repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
                if isKeyJustPressed(0x31) then
                    sampSendChat('/do В левой руке находится дипломат с лицензиями.')
                    wait(2100)
                    sampSendChat('/me открыл'..Sex..' кейс и вытащил'..Sex..' из него нужную лицензию')
                    wait(2100)
                    sampSendChat('/me взял'..Sex..' в руку ручку, после чего заполнил'..Sex..' лицензию')
                    wait(2100)
                    sampSendChat('/todo Вот Ваша лицензия*после чего передал'..Sex..' лицензию человеку напротив')
                    wait(2100)
                    sampSendChat('/selllic '..tid..' '..vid)
                    if Toggle['AutoScreen'].v then TimeScreen() end
                elseif isKeyJustPressed(0x32) then
                    sampSendChat('У Вас проблемы с документами, я не могу продать Вам лицензию.')
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
        sampSendChat('Здравствуйте, я страховой агент '..rpnick..'. На какой срок хотели-бы застраховать свой транспорт?')
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Для продолжения нажмите - {58ACFA}1{FFFFFF}. Отмена - {58ACFA}2{FFFFFF}.', -1)
        repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
        if isKeyJustPressed(0x31) then
            sampSendChat('Хорошо, предоставьте мне Ваш паспорт, мед. карту и ПТС.')
                sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Критерии: {58ACFA}18+ лет{FFFFFF} • Пройденый мед. осмотр', -1) wait(1)
                sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Для продолжения нажмите - {58ACFA}1{FFFFFF}. Если не допущен, то нажмите - {58ACFA}2{FFFFFF}. Отмена - {58ACFA}3{FFFFFF}.', -1)
                repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32) or isKeyJustPressed(0x33)
                if isKeyJustPressed(0x31) then
                    sampSendChat('/do Кейс с бланками и документами, талонами и страховкой в правой руке.')
                    wait(2100)
                    sampSendChat('/me открыл'..Sex..' кейс, достал'..Sex..' документы, после чего начал'..Sex..' заполнять их')
                    wait(2100)
                    sampSendChat('/me ниже поставил'..Sex..' печать "License center at", дату и подпись')
                    wait(2100)
                    sampSendChat('/me после продажи страховки, всё аккуратно сложил'..Sex..' кейс')
                    wait(2100)
                    sampSendChat('/me передал'..Sex..' страховку человеку напротив')
                    wait(200)
                    sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Впишите срок: 10 дней - {58ACFA}1{FFFFFF}, 30 дней - {58ACFA}2{FFFFFF}, 60 дней - {58ACFA}3', -1)
                    sampSetChatInputEnabled(true)
                    sampSetChatInputText('/insurance '..tid..' ')
                    repeat wait(0) until isKeyJustPressed(0x0D)
                    if Toggle['AutoScreen'].v then TimeScreen() end
                elseif isKeyJustPressed(0x32) then
                    sampSendChat('У Вас проблемы с документами, я не могу продать Вам страховку.')
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
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Добрый день сотрудники, сегодня я расскажу вам... ')
                wait(2000)
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ...Лекцию про "Транспорт в Лицензионном Центре".')
                wait(2000)
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотруднику разрешается брать автомобиль "Premier" с должности...')
                wait(2000)
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ..."Экзаменатор" с разрешения Руководства, только с внешней парковки..')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Если Вы возьмёте Автомобиль без разрешения, Вы получите Выговор.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Вертолёт "Maverick" разрешается брать с должности...')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ... "Менеджер" и выше, но сугубо в рабочих целях.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' За нарушение этого правила Вы получите Выговор.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Парковкой для личного транспорта сотрудника является территория...')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ...за воротами: пространство возле заднего входа и возле гаража.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' За парковку в неположенном месте полагается устная беседа.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Спасибо за внимание!')
            else
                sampSendChat('/f Добрый день сотрудники, сегодня я расскажу вам... ')
                wait(2000)
                sampSendChat('/f ...Лекцию про "Транспорт в Лицензионном Центре".')
                wait(2000)
                sampSendChat('/f Сотруднику разрешается брать автомобиль "Premier" с должности...')
                wait(2000)
                sampSendChat('/f ..."Экзаменатор" с разрешения Руководства, только с внешней парковки..')
                wait(2000)
                sampSendChat('/f Если Вы возьмёте Автомобиль без разрешения, Вы получите Выговор.')
                wait(2000)
                sampSendChat('/f Вертолёт "Maverick" разрешается брать с должности...')
                wait(2000)
                sampSendChat('/f ... "Менеджер" и выше, но сугубо в рабочих целях.')
                wait(2000)
                sampSendChat('/f За нарушение этого правила Вы получите Выговор.')
                wait(2000)
                sampSendChat('/f Парковкой для личного транспорта сотрудника является территория...')
                wait(2000)
                sampSendChat('/f ...за воротами: пространство возле заднего входа и возле гаража.')
                wait(2000)
                sampSendChat('/f За парковку в неположенном месте полагается устная беседа.')
                wait(2000)
                sampSendChat('/f Спасибо за внимание!')
            end
            if Toggle['AutoScreen'].v then TimeScreen() end
        else
            sampSendChat('Добрый день сотрудники, сегодня я расскажу вам... ')
            wait(2000)
            sampSendChat('...Лекцию про "Транспорт в Лицензионном Центре".')
            wait(2000)
            sampSendChat('Сотруднику разрешается брать автомобиль "Premier" с должности...')
            wait(2000)
            sampSendChat('..."Экзаменатор" с разрешения Руководства, только с внешней парковки..')
            wait(2000)
            sampSendChat('Если Вы возьмёте Автомобиль без разрешения, Вы получите Выговор.')
            wait(2000)
            sampSendChat('Вертолёт "Maverick" разрешается брать с должности...')
            wait(2000)
            sampSendChat('... "Менеджер" и выше, но сугубо в рабочих целях.')
            wait(2000)
            sampSendChat('За нарушение этого правила Вы получите Выговор.')
            wait(2000)
            sampSendChat('Парковкой для личного транспорта сотрудника является территория...')
            wait(2000)
            sampSendChat('...за воротами: пространство возле заднего входа и возле гаража.')
            wait(2000)
            sampSendChat('За парковку в неположенном месте полагается устная беседа.')
            wait(2000)
            sampSendChat('Спасибо за внимание!')
            if Toggle['AutoScreen'].v then TimeScreen() end
        end
	end)
end

function EticetSub()
	lua_thread.create(function()
        if Toggle['LecF'].v then
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Добрый день сотрудники,сегодня я расскажу вам Лекцию про "Этикет и Субординацию".')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотрудник обязан вежливо разговаривать с клиентами, используя обращение на "Вы".')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотрудникам запрещается оскорблять и унижать...')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ...клиентов или сотрудников Лицензионного Центра.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' За прямое оскорбление или унижение вас уволят.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотруднику запрещается использовать нецензурную лексику на рабочем месте.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотрудник обязан обращаться к Руководству на "Вы".')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотрудник имеет право разговаривать с коллегами,...')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ...не имеющими статус Руководства, на "Ты".')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' За нарушение Субординации вы получите Выговор.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Спасибо за внимание!')
            else
                sampSendChat('/f Добрый день сотрудники,сегодня я расскажу вам Лекцию про "Этикет и Субординацию".')
                wait(2000)
                sampSendChat('/f Сотрудник обязан вежливо разговаривать с клиентами, используя обращение на "Вы".')
                wait(2000)
                sampSendChat('/f Сотрудникам запрещается оскорблять и унижать...')
                wait(2000)
                sampSendChat('/f ...клиентов или сотрудников Лицензионного Центра.')
                wait(2000)
                sampSendChat('/f За прямое оскорбление или унижение вас уволят.')
                wait(2000)
                sampSendChat('/f Сотруднику запрещается использовать нецензурную лексику на рабочем месте.')
                wait(2000)
                sampSendChat('/f Сотрудник обязан обращаться к Руководству на "Вы".')
                wait(2000)
                sampSendChat('/f Сотрудник имеет право разговаривать с коллегами,...')
                wait(2000)
                sampSendChat('/f ...не имеющими статус Руководства, на "Ты".')
                wait(2000)
                sampSendChat('/f За нарушение Субординации вы получите Выговор.')
                wait(2000)
                sampSendChat('/f Спасибо за внимание!')
            end
            if Toggle['AutoScreen'].v then TimeScreen() end 
        else
            sampSendChat('Добрый день сотрудники,сегодня я расскажу вам Лекцию про "Этикет и Субординацию".')
            wait(2000)
            sampSendChat('Сотрудник обязан вежливо разговаривать с клиентами, используя обращение на "Вы".')
            wait(2000)
            sampSendChat('Сотрудникам запрещается оскорблять и унижать...')
            wait(2000)
            sampSendChat('...клиентов или сотрудников Лицензионного Центра.')
            wait(2000)
            sampSendChat('За прямое оскорбление или унижение вас уволят.')
            wait(2000)
            sampSendChat('Сотруднику запрещается использовать нецензурную лексику на рабочем месте.')
            wait(2000)
            sampSendChat('Сотрудник обязан обращаться к Руководству на "Вы".')
            wait(2000)
            sampSendChat('Сотрудник имеет право разговаривать с коллегами,...')
            wait(2000)
            sampSendChat('...не имеющими статус Руководства, на "Ты".')
            wait(2000)
            sampSendChat('За нарушение Субординации вы получите Выговор.')
            wait(2000)
            sampSendChat('Спасибо за внимание!')
            if Toggle['AutoScreen'].v then TimeScreen() end
        end
	end)
end

function RulesUseR()
	lua_thread.create(function()
        if Toggle['LecF'].v then
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Добрый день сотрудники,сегодня я расскажу вам "Правила использования Рации".')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотрудник имеет право пользоваться рацией организации в любое время.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотруднику запрещается рекламировать продажу домов, транспорта и иного имущества в рацию.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотруднику запрещается игнорировать обращение в рацию.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотруднику запрещается повторять фразу 3 и более раз.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Флуд 3-х и более строк')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' За бред в Рацию сотрудник тоже получает Выговор.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Большое спасибо за внимание!')
            else
                sampSendChat('/f Добрый день сотрудники,сегодня я расскажу вам "Правила использования Рации".')
                wait(2000)
                sampSendChat('/f Сотрудник имеет право пользоваться рацией организации в любое время.')
                wait(2000)
                sampSendChat('/f Сотруднику запрещается рекламировать продажу домов, транспорта и иного имущества в рацию.')
                wait(2000)
                sampSendChat('/f Сотруднику запрещается игнорировать обращение в рацию.')
                wait(2000)
                sampSendChat('/f Сотруднику запрещается повторять фразу 3 и более раз.')
                wait(2000)
                sampSendChat('/fn Флуд 3-х и более строк')
                wait(2000)
                sampSendChat('/f За бред в Рацию сотрудник тоже получает Выговор.')
                wait(2000)
                sampSendChat('/f Большое спасибо за внимание!')
            end
            if Toggle['AutoScreen'].v then TimeScreen() end 
        else
            sampSendChat('Добрый день сотрудники,сегодня я расскажу вам "Правила использования Рации".')
            wait(2000)
            sampSendChat('Сотрудник имеет право пользоваться рацией организации в любое время.')
            wait(2000)
            sampSendChat('Сотруднику запрещается рекламировать продажу домов, транспорта и иного имущества в рацию.')
            wait(2000)
            sampSendChat('Сотруднику запрещается игнорировать обращение в рацию.')
            wait(2000)
            sampSendChat('Сотруднику запрещается повторять фразу 3 и более раз.')
            wait(2000)
            sampSendChat('/n Флуд 3-х и более строк')
            wait(2000)
            sampSendChat('За бред в Рацию сотрудник тоже получает Выговор.')
            wait(2000)
            sampSendChat('Большое спасибо за внимание!')
            if Toggle['AutoScreen'].v then TimeScreen() end
        end
	end)
end

function GeneralRules()
	lua_thread.create(function()
        if Toggle['LecF'].v then
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Добрый день сотрудники,сегодня я расскажу вам Лекцию про...')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ..."Основные правила и обязанности ЛЦ".')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотрудникам Лицензионного центра запрещено прогуливать рабочий день.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотрудникам запрещено носить при себе огнестрельное оружие в открытом виде.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотрудникам запрещено употреблять алкоголь в рабочее время.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Все сотрудники обязаны соблюдать специальный дресс-код, при нарушении он получит выговор.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотрудники обязаны соблюдать действующий Устав ЛЦ и иное законодательство Республики.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотрудник обязан оказывать помощь коллегам и Руководству в рабочем процессе.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотрудник не имеет права игнорировать приказы Руководства, только...')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ...если они не противоречат действующим Законам.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Большое спасибо за внимание!')
            else 
                sampSendChat('/f Добрый день сотрудники,сегодня я расскажу вам Лекцию про...')
                wait(2000)
                sampSendChat('/f ..."Основные правила и обязанности ЛЦ".')
                wait(2000)
                sampSendChat('/f Сотрудникам Лицензионного центра запрещено прогуливать рабочий день.')
                wait(2000)
                sampSendChat('/f Сотрудникам запрещено носить при себе огнестрельное оружие в открытом виде.')
                wait(2000)
                sampSendChat('/f Сотрудникам запрещено употреблять алкоголь в рабочее время.')
                wait(2000)
                sampSendChat('/f Все сотрудники обязаны соблюдать специальный дресс-код, при нарушении он получит выговор.')
                wait(2000)
                sampSendChat('/f Сотрудники обязаны соблюдать действующий Устав ЛЦ и иное законодательство Республики.')
                wait(2000)
                sampSendChat('/f Сотрудник обязан оказывать помощь коллегам и Руководству в рабочем процессе.')
                wait(2000)
                sampSendChat('/f Сотрудник не имеет права игнорировать приказы Руководства, только...')
                wait(2000)
                sampSendChat('/f ...если они не противоречат действующим Законам.')
                wait(2000)
                sampSendChat('/f Большое спасибо за внимание!') 
            end
            if Toggle['AutoScreen'].v then TimeScreen() end
        else
            sampSendChat('Добрый день сотрудники,сегодня я расскажу вам Лекцию про...')
            wait(2000)
            sampSendChat('..."Основные правила и обязанности ЛЦ".')
            wait(2000)
            sampSendChat('Сотрудникам Лицензионного центра запрещено прогуливать рабочий день.')
            wait(2000)
            sampSendChat('Сотрудникам запрещено носить при себе огнестрельное оружие в открытом виде.')
            wait(2000)
            sampSendChat('Сотрудникам запрещено употреблять алкоголь в рабочее время.')
            wait(2000)
            sampSendChat('Все сотрудники обязаны соблюдать специальный дресс-код, при нарушении он получит выговор.')
            wait(2000)
            sampSendChat('Сотрудники обязаны соблюдать действующий Устав ЛЦ и иное законодательство Республики.')
            wait(2000)
            sampSendChat('Сотрудник обязан оказывать помощь коллегам и Руководству в рабочем процессе.')
            wait(2000)
            sampSendChat('Сотрудник не имеет права игнорировать приказы Руководства, только...')
            wait(2000)
            sampSendChat('...если они не противоречат действующим Законам.')
            wait(2000)
            sampSendChat('Большое спасибо за внимание!')
            if Toggle['AutoScreen'].v then TimeScreen() end
        end
	end)
end

function RulesUseDesk()
    lua_thread.create(function()
        if Toggle['LecF'].v then
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Добрый день сотрудники,сегодня я расскажу вам Правила использования Доски.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' На доске разрешается писать только "Заместителю Директора" и "Директору".')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' За нарушение этого правила вы получите Строгий выговор.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' 2/3')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотрудник обязан использовать доску только для выставления ценовой...')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' ...политики ЛЦ и информации для сотрудников.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' За нарушение этого правила вы получите выговор.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' За написание матерных или оскорбительных выражений на доске.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Сотрудник будет строго наказан.')
                wait(2000) 
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Всего доброго!')
            else 
                sampSendChat('/f Добрый день сотрудники,сегодня я расскажу вам Правила использования Доски.')
                wait(2000)
                sampSendChat('/f На доске разрешается писать только "Заместителю Директора" и "Директору".')
                wait(2000)
                sampSendChat('/f За нарушение этого правила вы получите Строгий выговор.')
                wait(2000)
                sampSendChat('/fn 2/3')
                wait(2000)
                sampSendChat('/f Сотрудник обязан использовать доску только для выставления ценовой...')
                wait(2000)
                sampSendChat('/f ...политики ЛЦ и информации для сотрудников.')
                wait(2000)
                sampSendChat('/f За нарушение этого правила вы получите выговор.')
                wait(2000)
                sampSendChat('/f За написание матерных или оскорбительных выражений на доске.')
                wait(2000)
                sampSendChat('/f Сотрудник будет строго наказан.')
                wait(2000)
                sampSendChat('/f Всего доброго!')
            end
            if Toggle['AutoScreen'].v then TimeScreen() end 
        else
            sampSendChat('Добрый день сотрудники,сегодня я расскажу вам Правила использования Доски.')
            wait(2000)
            sampSendChat('На доске разрешается писать только "Заместителю Директора" и "Директору".')
            wait(2000)
            sampSendChat('За нарушение этого правила вы получите Строгий выговор.')
            wait(2000)
            sampSendChat('/n 2/3')
            wait(2000)
            sampSendChat('Сотрудник обязан использовать доску только для выставления ценовой...')
            wait(2000)
            sampSendChat('...политики ЛЦ и информации для сотрудников.')
            wait(2000)
            sampSendChat('За нарушение этого правила вы получите выговор.')
            wait(2000)
            sampSendChat('За написание матерных или оскорбительных выражений на доске.')
            wait(2000)
            sampSendChat('Сотрудник будет строго наказан.')
            wait(2000)
            sampSendChat('Всего доброго!')
            if Toggle['AutoScreen'].v then TimeScreen() end
        end
	end)
end

function rangup(arg)
    lua_thread.create(function()
        if arg == 2 then
            sampSendChat('/do В кармане лежит пейджер.')
            wait(2000)
            sampSendChat('/me достал'..Sex..' пейджер')
            wait(2000)
            sampSendChat('/do На пейдежере надпись "Список сотрудников".')
            wait(2000)
            sampSendChat('/me выбрал'..Sex..' сотрудника, затем нажал'..Sex..' кнопку "Повышение в должности"')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Впишите {58ACFA}id{FFFFFF} сотрудника', -1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/rang ')
        elseif arg == 1 then
            sampSendChat('/do В кармане лежит пейджер.')
            wait(2000)
            sampSendChat('/me достал'..Sex..' пейджер')
            wait(2000)
            sampSendChat('/do На пейдежере надпись "Список сотрудников".')
            wait(2000)
            sampSendChat('/me выбрал'..Sex..' сотрудника, затем нажал'..Sex..' кнопку "Повышение в должности"')
            wait(2000)
            sampSendChat('/rang '..tid)
        end
	end)
end

function giveskin(arg)
    lua_thread.create(function()
        if arg == 2 then
            sampSendChat('/do На плече висит сумка.')
            wait(2000)
            sampSendChat('/me спустил'..Sex..' с плеча сумку, поставил'..Sex..' ее напол')
            wait(2000)
            sampSendChat('/me достал'..Sex..' комплект рабочей одежды, после чего передал'..Sex..' человеку напротив')
            wait(2000)
            sampSendChat('/todo Вам идёт*закрывая сумку')
            wait(2000)
            sampSendChat('/me повесил'..Sex..' сумку на плечо')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Впишите {58ACFA}id{FFFFFF} сотрудника', -1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/setskin ')
        elseif arg == 1 then
            sampSendChat('/do На плече висит сумка.')
            wait(2000)
            sampSendChat('/me спустил'..Sex..' с плеча сумку, поставил'..Sex..' ее напол')
            wait(2000)
            sampSendChat('/me достал'..Sex..' комплект рабочей одежды, после чего передал'..Sex..' человеку напротив')
            wait(2000)
            sampSendChat('/todo Вам идёт*закрывая сумку')
            wait(2000)
            sampSendChat('/me повесил'..Sex..' сумку на плечо')
            wait(2000)
            sampSendChat('/setskin '..tid)
        end
	end)
end

function givewarn(arg)
	lua_thread.create(function()
        if arg == 2 then
            sampSendChat('/me достал'..Sex..' из левого кармана КПК, включил'..Sex..' его')
            wait(2000)
            if Radio['Gender'].v == 1 then
                sampSendChat('/me зашёл в список сотрудников, нашёл нужного сотрудника, напротив него поставил галочку "Выговор"')
            else
                sampSendChat('/me зашла в список сотрудников, нашла нужного сотрудника, напротив него поставила галочку "Выговор"')
            end
            wait(2000)
            sampSendChat('/do Система внесла поправки в личное дело сотрудника.')
            wait(2000)
            sampSendChat('/me выключил'..Sex..' КПК, убрал'..Sex..' его в карман')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Впишите {58ACFA}id{FFFFFF} сотрудника и {58ACFA}причину{FFFFFF}', -1) wait(1)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Пример использования: {58ACFA}/fwarn [ID] АШ | Прогул ['..date..']', -1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/fwarn  ['..date..']')            
        elseif arg == 1 then
            sampSendChat('/me достал'..Sex..' из левого кармана КПК, включил'..Sex..' его')
            wait(2000)
            if Radio['Gender'].v == 1 then
                sampSendChat('/me зашёл в список сотрудников, нашёл нужного сотрудника, напротив него поставил галочку "Выговор"')
            else
                sampSendChat('/me зашла в список сотрудников, нашла нужного сотрудника, напротив него поставила галочку "Выговор"')
            end
            wait(2000)
            sampSendChat('/do Система внесла поправки в личное дело сотрудника.')
            wait(2000)
            sampSendChat('/me выключил'..Sex..' КПК, убрал'..Sex..' его в карман')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Впишите {58ACFA}причину{FFFFFF}', -1) wait(1)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Пример использования: {58ACFA}/fwarn '..tid..' АШ | Прогул ['..date..']', -1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/fwarn '..tid..'  ['..date..']')
        end
	end)
end

function givewarnoff()
	lua_thread.create(function()
        sampSendChat('/me достал'..Sex..' из левого кармана КПК, включил'..Sex..' его')
        wait(2000)
        if Radio['Gender'].v == 1 then
            sampSendChat('/me зашёл в список сотрудников, нашёл нужного сотрудника, напротив него поставил галочку "Выговор"')
        else
            sampSendChat('/me зашла в список сотрудников, нашла нужного сотрудника, напротив него поставила галочку "Выговор"')
        end
        wait(2000)
        sampSendChat('/do Система внесла поправки в личное дело сотрудника.')
        wait(2000)
        sampSendChat('/me выключил'..Sex..' КПК, убрал'..Sex..' его в карман')
        wait(500)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Впишите {58ACFA}Nick_Name{FFFFFF} сотрудника и {58ACFA}причину{FFFFFF}', -1) wait(1)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Пример использования: {58ACFA}/fwarnoff Banana_Blackstone АШ | Прогул ['..date..']', -1)
        sampSetChatInputEnabled(true)
        sampSetChatInputText('/fwarnoff  ['..date..']') 
	end)
end

function takeoffwarn(arg)
	lua_thread.create(function()
        if arg == 2 then
            sampSendChat('/me достал'..Sex..' из левого кармана КПК, включил'..Sex..' его')
            wait(2000)
            if Radio['Gender'].v == 1 then
                sampSendChat('/me зашёл в список сотрудников, нашёл нужного сотрудника, напротив него поставил галочку "Снятие выговора"')
            else
                sampSendChat('/me зашла в список сотрудников, нашла нужного сотрудника, напротив него поставила галочку "Снятие выговора"')
            end
            wait(2000)
            sampSendChat('/do Система внесла поправки в личное дело сотрудника.')
            wait(2000)
            sampSendChat('/me выключил'..Sex..' КПК, убрал'..Sex..' его в карман')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Впишите {58ACFA}id{FFFFFF} сотрудника и {58ACFA}причину{FFFFFF}', -1) wait(1)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Пример использования: {58ACFA}/unfwarn [ID] АШ | Отработал ['..date..']', -1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/unfwarn  ['..date..']') 
        elseif arg == 1 then
            sampSendChat('/me достал'..Sex..' из левого кармана КПК, включил'..Sex..' его')
            wait(2000)
            if Radio['Gender'].v == 1 then
                sampSendChat('/me зашёл в список сотрудников, нашёл нужного сотрудника, напротив него поставил галочку "Снятие выговора"')
            else
                sampSendChat('/me зашла в список сотрудников, нашла нужного сотрудника, напротив него поставила галочку "Снятие выговора"')
            end
            wait(2000)
            sampSendChat('/do Система внесла поправки в личное дело сотрудника.')
            wait(2000)
            sampSendChat('/me выключил'..Sex..' КПК, убрал'..Sex..' его в карман')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Впишите {58ACFA}причину{FFFFFF}', -1) wait(1)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Пример использования: {58ACFA}/unfwarn '..tid..' АШ | Отработал ['..date..']', -1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/unfwarn '..tid..'  ['..date..']') 
        end
	end)
end

function uninvite(arg)
	lua_thread.create(function()
        if arg == 2 then
            sampSendChat('/me достал'..Sex..' из левого кармана КПК, включил'..Sex..' его')
            wait(2000)
            if Radio['Gender'].v == 1 then
                sampSendChat('/me зашёл в список сотрудников, нашёл нужного сотрудника, напротив него поставил галочку "Увольнение"')
            else
                sampSendChat('/me зашла в список сотрудников, нашла нужного сотрудника, напротив него поставила галочку "Увольнение"')
            end
            wait(2000)
            sampSendChat('/do Система аннулировала личное дело сотрудника.')
            wait(2000)
            sampSendChat('/me выключил'..Sex..' КПК, убрал'..Sex..' его в карман')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Впишите {58ACFA}id{FFFFFF} сотрудника и {58ACFA}причину{FFFFFF}', -1) wait(1)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Пример использования: {58ACFA}/uninvite [ID] АШ | Проф.непригоден ['..date..']', -1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/uninvite  ['..date..']') 
        elseif arg == 1 then
            sampSendChat('/me достал'..Sex..' из левого кармана КПК, включил'..Sex..' его')
            wait(2000)
            if Radio['Gender'].v == 1 then
                sampSendChat('/me зашёл в список сотрудников, нашёл нужного сотрудника, напротив него поставил галочку "Увольнение"')
            else
                sampSendChat('/me зашла в список сотрудников, нашла нужного сотрудника, напротив него поставила галочку "Увольнение"')
            end
            wait(2000)
            sampSendChat('/do Система аннулировала личное дело сотрудника.')
            wait(2000)
            sampSendChat('/me выключил'..Sex..' КПК, убрал'..Sex..' его в карман')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Впишите {58ACFA}причину{FFFFFF}', -1) wait(1)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Пример использования: {58ACFA}/uninvite '..tid..' АШ | Проф.непригоден ['..date..']', -1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/uninvite '..tid..'  ['..date..']')
        end
	end)
end

function uninviteoff()
	lua_thread.create(function()
        sampSendChat('/me достал'..Sex..' из левого кармана КПК, включил'..Sex..' его')
        wait(2000)
        if Radio['Gender'].v == 1 then
            sampSendChat('/me зашёл в список сотрудников, нашёл нужного сотрудника, напротив него поставил галочку "Увольнение"')
        else
            sampSendChat('/me зашла в список сотрудников, нашла нужного сотрудника, напротив него поставила галочку "Увольнение"')
        end
        wait(2000)
        sampSendChat('/do Система аннулировала личное дело сотрудника.')
        wait(2000)
        sampSendChat('/me выключил'..Sex..' КПК, убрал'..Sex..' его в карман')
        wait(500)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Впишите {58ACFA}Nick_Name{FFFFFF} сотрудника и {58ACFA}причину{FFFFFF}', -1) wait(1)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Пример использования: {58ACFA}/uninviteoff Banana_Blackstone АШ | Проф.непригоден ['..date..']', -1)
        sampSetChatInputEnabled(true)
        sampSetChatInputText('/uninviteoff  ['..date..']') 
	end)
end

function gobl(arg)
	lua_thread.create(function()
        if arg == 2 then
            sampSendChat('/me достал'..Sex..' из левого кармана КПК, включил'..Sex..' его')
            wait(2000)
            if Radio['Gender'].v == 1 then
                sampSendChat('/me зашел в базу данных Автошколы, после чего нажал на вкладку "Черный список"')
            else
                sampSendChat('/me зашла в базу данных Автошколы, после чего нажала на вкладку "Черный список"')
            end
            wait(2000)
            sampSendChat('/me сверил'..Sex..' данные из документов, после чего нажал'..Sex..' кнопку "Добавить"')
            wait(2000)
            sampSendChat('/do Идет загрузка...')
            wait(2000)
            sampSendChat('/do Человек добавлен в черный список.')
            wait(2000)
            sampSendChat('/me выключил'..Sex..' КПК, убрал'..Sex..' его в карман')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Впишите {58ACFA}id{FFFFFF} сотрудника', -1) wait(1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/black ') 
        elseif arg == 1 then
            sampSendChat('/me достал'..Sex..' из левого кармана КПК, включил'..Sex..' его')
            wait(2000)
            if Radio['Gender'].v == 1 then
                sampSendChat('/me зашел в базу данных Автошколы, после чего нажал на вкладку "Черный список"')
            else
                sampSendChat('/me зашла в базу данных Автошколы, после чего нажала на вкладку "Черный список"')
            end
            wait(2000)
            sampSendChat('/me сверил'..Sex..' данные из документов, после чего нажал'..Sex..' кнопку "Добавить"')
            wait(2000)
            sampSendChat('/do Идет загрузка...')
            wait(2000)
            sampSendChat('/do Человек добавлен в черный список.')
            wait(2000)
            sampSendChat('/me выключил'..Sex..' КПК, убрал'..Sex..' его в карман')
            wait(2000)
            sampSendChat('/black '..tid) 
        end
	end)
end

function gobloff(arg)
	lua_thread.create(function()
        sampSendChat('/me достал'..Sex..' из левого кармана КПК, включил'..Sex..' его')
        wait(2000)
        if Radio['Gender'].v == 1 then
            sampSendChat('/me зашел в базу данных Автошколы, после чего нажал на вкладку "Черный список"')
        else
            sampSendChat('/me зашла в базу данных Автошколы, после чего нажала на вкладку "Черный список"')
        end
        wait(2000)
        sampSendChat('/me сверил'..Sex..' данные из документов, после чего нажал'..Sex..' кнопку "Добавить"')
        wait(2000)
        sampSendChat('/do Идет загрузка...')
        wait(2000)
        sampSendChat('/do Человек добавлен в черный список.')
        wait(2000)
        sampSendChat('/me выключил'..Sex..' КПК, убрал'..Sex..' его в карман')
        wait(500)
        sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Впишите {58ACFA}Nick_Name{FFFFFF} сотрудника', -1) wait(1)
        --sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Пример использования: {58ACFA}/uninviteoff Banana_Blackstone АШ | Проф.непригоден ['..date..']', -1)
        sampSetChatInputEnabled(true)
        sampSetChatInputText('/offblack ') 
	end)
end

function backbl(arg)
    lua_thread.create(function()
        if arg == 2 then
            if Radio['Gender'].v == 1 then
                sampSendChat('/me достал пейджер, после чего зашёл в раздел "Чёрный список Автошколы"')
            else
                sampSendChat('/me достала пейджер, после чего зашла в раздел "Чёрный список Автошколы"')
            end        
            wait(2000)
            sampSendChat('/me нажал'..Sex..' на кнопку "Найти", после чего ввел'..Sex..' имя и фамилию человека в открывшемся окне, затем нажал'..Sex..' "Найти"')
            wait(2000)
            sampSendChat('/do Система начала искать данного человека.')
            wait(2000)
            sampSendChat('/do Спустя пару секунд на экране пейджера вылезло окошко: "Имя фамилия" найден. В этом же окне есть кнопки действия: "Вынести" и "Закрыть".')
            wait(2000)
            sampSendChat('/me нажал'..Sex..' на кнопку "Вынести" , затем убрал'..Sex..' пейджер в карман')
            wait(2000)
            sampSendChat('/do На экране пейджера вылезло уведомление: "Имя Фамилия" вынесен из чёрного списка Автошколы.')
            wait(500)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Введите команду: {58ACFA}/offblack {FFFFFF}или {58ACFA}/black', -1) wait(1)
            sampSetChatInputEnabled(true) 
        elseif arg == 1 then
            if Radio['Gender'].v == 1 then
                sampSendChat('/me достал пейджер, после чего зашёл в раздел "Чёрный список Автошколы"')
            else
                sampSendChat('/me достала пейджер, после чего зашла в раздел "Чёрный список Автошколы"')
            end        
            wait(2000)
            sampSendChat('/me нажал'..Sex..' на кнопку "Найти", после чего ввел'..Sex..' имя и фамилию человека в открывшемся окне, затем нажал'..Sex..' "Найти"')
            wait(2000)
            sampSendChat('/do Система начала искать данного человека.')
            wait(2000)
            sampSendChat('/do Спустя пару секунд на экране пейджера вылезло окошко: "'..targrpnick..'" найден. В этом же окне есть кнопки действия: "Вынести" и "Закрыть".')
            wait(2000)
            sampSendChat('/me нажал'..Sex..' на кнопку "Вынести" , затем убрал'..Sex..' пейджер в карман')
            wait(2000)
            sampSendChat('/do На экране пейджера вылезло уведомление: "'..targrpnick..'" вынесен из чёрного списка Автошколы.')
            wait(2000)
            sampSendChat('/black '..tid)
        end
	end)
end

function inviteFunc(st)
    lua_thread.create(function()
        if st == 1 then
            sampSendChat('Хорошо, вы нам подходите! Ожидайте выдачу формы и бейджика.')
            wait(2000)
            if Toggle['TagF'].v then -- '..u8:decode(Input['Tag'].v)..'
                sampSendChat('/f '..u8:decode(Input['Tag'].v)..' Человек около ресепшена подходит на стажировку.')
            else
                sampSendChat('/f Человек около ресепшена подходит на стажировку.')
            end
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Если вы лидер или заместитель, нажмите - {58ACFA}1{FFFFFF}. Если нет - {58ACFA}2{FFFFFF}.', -1)
            repeat wait(0) until isKeyJustPressed(0x31) or isKeyJustPressed(0x32)
            if isKeyJustPressed(0x31) then
                sampSendChat('/do На плече висит сумка.')
                wait(2000)
                sampSendChat('/do На пейдежере надпись "Список сотрудников"')
                wait(2000)
                sampSendChat('/me выбрал'..Sex..' сотрудника, затем нажал'..Sex..' кнопку "Повышение в должности"')
                wait(200)
                sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Впишите {58ACFA}id{FFFFFF} игрока', -1) wait(1)
                sampSetChatInputEnabled(true)
                sampSetChatInputText('/invite ')
                congr()
            elseif isKeyJustPressed(0x32) then
            end
        elseif st == 2 then
            sampSendChat('/do На плече висит сумка.')
            wait(2000)
            sampSendChat('/do На пейдежере надпись "Список сотрудников"')
            wait(2000)
            sampSendChat('/me выбрал'..Sex..' сотрудника, затем нажал'..Sex..' кнопку "Повышение в должности"')
            wait(200)
            sampAddChatMessage('{58ACFA}ASA{FFFFFF} • Впишите {58ACFA}id{FFFFFF} игрока', -1) wait(1)
            sampSetChatInputEnabled(true)
            sampSetChatInputText('/invite ')
            congr()
        elseif st == 3 then
            sampSendChat('/do На плече висит сумка.')
            wait(2000)
            sampSendChat('/do На пейдежере надпись "Список сотрудников"')
            wait(2000)
            sampSendChat('/me выбрал'..Sex..' сотрудника, затем нажал'..Sex..' кнопку "Повышение в должности"')
            wait(2000)
            sampSendChat('/invite '..tid)
        end
    end)
end

function congr()
    lua_thread.create(function()
        repeat wait(0) until isKeyJustPressed(0x0D) or isKeyJustPressed(0x1B) or isKeyJustPressed(0x75)
            if isKeyJustPressed(0x0D) then
                sampSendChat('Поздравляю!')
            elseif isKeyJustPressed(0x1B) or isKeyJustPressed(0x75) then
            end
    end)
end

function latest_update()
	sampShowDialog(0, '{58ACFA}AutoSchool Assist', '{FFFFFF}У Вас первая версия скрипта', 'Закрыть')
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

function makeScreen(disable) -- если передать true, интерфейс и чат будут скрыты
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