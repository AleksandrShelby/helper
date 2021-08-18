script_name('Проверка ПРО/Устав/ППЭ')  
script_author('Alexander Twix & Ash Lavashyan(redactor)') 
script_description('Скрипт помогает принимать ПРО/Устав/ППЭ у практикантов СМИ')

require "lib.moonloader"
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
local keys = require "vkeys" 
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

update_state = false
local script_vers = 3
local script_vers_text = "1.10"
local update_url = "https://raw.githubusercontent.com/AleksandrShelby/helper/main/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "https://github.com/AleksandrShelby/helper/blob/main/Exam_Helper.luac?raw=true" -- тут свою ссылку
local script_path = thisScript().path
local tag ='{0066ff}[Проверка]: '
local main_color = 0x0066ff
local main_color_text = "{0066ff}"
local white_color = "{FFFFFF}"
local main_window_state = imgui.ImBool(false)
local text_buffer = imgui.ImBuffer(256)

function imgui.TextColoredRGB(text)
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

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
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
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end

    render_text(text)
end
function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
    style.WindowPadding                = ImVec2(4.0, 4.0)
    style.WindowRounding               = 7
    style.WindowTitleAlign             = ImVec2(0.5, 0.5)
    style.FramePadding                 = ImVec2(4.0, 3.0)
    style.ItemSpacing                  = ImVec2(8.0, 4.0)
    style.ItemInnerSpacing             = ImVec2(4.0, 4.0)
    style.ChildWindowRounding          = 7
    style.FrameRounding                = 7
    style.ScrollbarRounding            = 7
    style.GrabRounding                 = 7
    style.IndentSpacing                = 21.0
    style.ScrollbarSize                = 13.0
    style.GrabMinSize                  = 10.0
    style.ButtonTextAlign              = ImVec2(0.5, 0.5)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 1.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.96)
    colors[clr.Border]                 = ImVec4(0.73, 0.36, 0.00, 0.00)
    colors[clr.FrameBg]                = ImVec4(0.49, 0.24, 0.00, 1.00)
    colors[clr.FrameBgHovered]         = ImVec4(0.65, 0.32, 0.00, 1.00)
    colors[clr.FrameBgActive]          = ImVec4(0.73, 0.36, 0.00, 1.00)
    colors[clr.TitleBg]                = ImVec4(0.15, 0.11, 0.09, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.73, 0.36, 0.00, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.15, 0.11, 0.09, 0.51)
    colors[clr.MenuBarBg]              = ImVec4(0.62, 0.31, 0.00, 1.00)
    colors[clr.CheckMark]              = ImVec4(1.00, 0.49, 0.00, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.84, 0.41, 0.00, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.49, 0.00, 1.00)
    colors[clr.Button]                 = ImVec4(0.73, 0.36, 0.00, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.73, 0.36, 0.00, 1.00)
    colors[clr.ButtonActive]           = ImVec4(1.00, 0.50, 0.00, 1.00)
    colors[clr.Header]                 = ImVec4(0.49, 0.24, 0.00, 1.00)
    colors[clr.HeaderHovered]          = ImVec4(0.70, 0.35, 0.01, 1.00)
    colors[clr.HeaderActive]           = ImVec4(1.00, 0.49, 0.00, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.49, 0.24, 0.00, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.49, 0.24, 0.00, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.48, 0.23, 0.00, 1.00)
    colors[clr.ResizeGripHovered]      = ImVec4(0.78, 0.38, 0.00, 1.00)
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.49, 0.00, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.83, 0.41, 0.00, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.99, 0.00, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.93, 0.46, 0.00, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.33, 0.33, 0.33, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.39, 0.39, 0.39, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.48, 0.48, 0.48, 1.00)
    colors[clr.CloseButton]            = colors[clr.FrameBg]
    colors[clr.CloseButtonHovered]     = colors[clr.FrameBgHovered]
    colors[clr.CloseButtonActive]      = colors[clr.FrameBgActive]
end
apply_custom_style()
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand("cnn", cmd_cnn)
	
	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick = sampGetPlayerNickname(id)
	
	imgui.Process = false
	sampAddChatMessage(tag.."{FFFFFF}Приветствую,{0066ff} "..nick.."["..id.."]{FFFFFF}!", main_color)
	sampAddChatMessage(tag.."{FFFFFF}Для того чтобы запустить скрипт, введите команду {0066ff}/cnn", main_color)
	sampAddChatMessage(tag.."{FFFFFF}Скрипт написал нубасина Alexander Twix, подкорректировал Ash Lavashyan", main_color)
	downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("Доступно обновление! Версия: " .. updateIni.info.vers_text, main_color)
                update_state = true
            end
            os.remove(update_path)
        end
    end)
	
	while true do
        wait(0)

        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("Скрипт успешно обновлен!", main_color)
                    thisScript():reload()
                end
            end)
            break
        end

	end
end	

function cmd_cnn(arg)
	main_window_state.v = not main_window_state.v
	imgui.Process = main_window_state.v
 end
 function imgui.Hint(text, delay)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5 -- Скорость появления
        if os.clock() >= go_hint then
            imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
                imgui.PushStyleColor(imgui.Col.PopupBg, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
                    imgui.BeginTooltip()
                    imgui.PushTextWrapPos(450)
                    imgui.TextUnformatted(text)
                    if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
                    imgui.PopTextWrapPos()
                    imgui.EndTooltip()
                imgui.PopStyleColor()
            imgui.PopStyleVar()
        end
    end
end
function imgui.VerticalSeparator()
    local p = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x, p.y + imgui.GetContentRegionMax().y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Separator]))
end

function imgui.OnDrawFrame()
	if not main_window_state.v then
		imgui.Process = false
	end

    if main_window_state.v then
        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(475, 550), imgui.Cond.FirstUseEver)
	end
	imgui.Begin(u8"Проверка ПРО/Устав/ППЭ/ПРГ", main_window_state)
	if imgui.CollapsingHeader(u8'Проверка Правил Редактирования Объявлений') then
 
	if imgui.Button(u8"Готовы?##1") then
			lua_thread.create(function()
				sampSendChat("Вы готовы сдать ПРО?")
				wait(1000)
				sampSendChat("/time")
			end)
		end
		imgui.SameLine()
		if imgui.Button(u8"Верно!##1") then
				sampSendChat("Верно!")
		end
		imgui.SameLine()
		if imgui.Button(u8"Неверно!##1") then
				sampSendChat("Неверно!")
		end
		imgui.SameLine()
		if imgui.Button(u8"Успешно сдал!##1") then
				sampSendChat("Поздравляю! Вы сдали Правила редактирования объявлений!")
		end
		imgui.SameLine()
		if imgui.Button(u8"Не успешно сдал!##1") then
				sampSendChat("К сожалению вы не сдали ПРО!")
		end
		imgui.SameLine()
		if imgui.Button(u8"/time##1") then
				sampSendChat("/time")
		end
		imgui.Separator()
		imgui.SetCursorPos(imgui.ImVec2(3,76))
			if imgui.Button(u8"Расшифровка ПРО") then
				sampSendChat("Как расшифруеться ПРО?")
		end
		imgui.SameLine()
		--imgui.VerticalSeparator()
		imgui.SetCursorPos(imgui.ImVec2(178,76))
		if imgui.Button(u8"Ответ##1") then
				sampSendChat("Првильный ответ: Правила редактирования объявлений!")
		end
		imgui.SameLine()
		--imgui.VerticalSeparator()
		imgui.SetCursorPos(imgui.ImVec2(3,102))
			if imgui.Button(u8"Иностранные языки") then
				sampSendChat("Можно ли использовать иностранные языки в объявлениях?")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,102))
		if imgui.Button(u8"Ответ##2") then
				sampSendChat("Правильный ответ: Нельзя, Исключение: Название семей")
		end
		if imgui.Button(u8"Объявы от одного") then
				sampSendChat("В каких случаях можно редактировать объявление от одного и того же человека")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,128))
		if imgui.Button(u8"Ответ##3") then
				sampSendChat("Правильный ответ: если в списке меньше 5-и объявлений")
		end
		--imgui.Separator()
		if imgui.Button(u8"Продам ковш") then
				sampSendChat("Отредактируйте объявление: Продам ковш за 25миллионов")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,154))
		if imgui.Button(u8"Ответ##4") then
				sampSendChat("Правильный ответ: Отказ. Не рекламируем продажу/покупку тюнинга")
		end
		if imgui.Button(u8"Магазин одежды у Казика") then
				sampSendChat("Отредактируйте объявление: Продам магазин одежды у казино")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,180))
		if imgui.Button(u8"Ответ##5") then
				sampSendChat("Правильный ответ: Продам б/з магазин одежды в г.Лас-Вентурас. Цена: договорная")
		end
		--imgui.Separator()
		if imgui.Button(u8"Продам 485 дом") then
				sampSendChat("Отредактируйте объявление: Продам 485 дом за дешево, звоните 1414194")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,206))
		if imgui.Button(u8"Ответ##6") then
				sampSendChat("Правильный ответ: Отказ. Укажите местоположение(город)")
		end
		if imgui.Button(u8"Куплю наркотики") then
				sampSendChat("Отредактируйте объявление: Куплю наркотики за 5к штуку")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,232))
		if imgui.Button(u8"Ответ##7") then
				sampSendChat("Правильный ответ: Отказ. Не рекламируем такие вещевства")
		end
		--imgui.Separator()
			if imgui.Button(u8"Куплю нимб +12") then
				sampSendChat("Отредактируйте объявление: Куплю нимб с надписью +12 за 60кк")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,258))
		if imgui.Button(u8"Ответ##8") then
				sampSendChat("Правильный ответ: Отказ. Не рекламируем данный а/с")
		end
		if imgui.Button(u8"Куплю отмычки от ТСР") then
				sampSendChat("Отредактируйте объявление: Куплю срочно отмычки от ТСР за штуку 100к")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,284))
		if imgui.Button(u8"Ответ##9") then
				sampSendChat("Правильный ответ: Отказ. Не рекламируем данный р/с")
		end
		--imgui.Separator()
			if imgui.Button(u8"Куплю 4х донат") then
				sampSendChat("Отредактируйте объявление: Куплю 4х донат")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,310))
		if imgui.Button(u8"Ответ##10") then
				sampSendChat("Правильный ответ: Отказ. Не рекламируем данный товар")
		end
		if imgui.Button(u8"Продам банд. респекты") then
				sampSendChat("Отредактируйте объявление: Продам бандитские респекти в кол-ве 1450 звоните")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,334))
		if imgui.Button(u8"Ответ##11") then
				sampSendChat("Правильный ответ: Отказ. Не рекламируем данный р/с")
		end
		if imgui.Button(u8"Дом в новостройке") then
				sampSendChat("Отредактируйте объявление: Продам квартиру в новостройке")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,362))
		if imgui.Button(u8"Ответ##12") then
				sampSendChat("Правильный ответ: Продам квартиру в новостройке. Цена: договорная")
		end
		--imgui.Separator()
		if imgui.Button(u8"Куплю видеокарты") then
				sampSendChat("Отредактируйте объявление: Куплю видеокарты за 600к")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,388))
		if imgui.Button(u8"Ответ##13") then
				sampSendChat("Правильный ответ: Куплю видеокарты. Бюджет: 600.000$")
		end
		if imgui.Button(u8"Продам НРГ-500") then
				sampSendChat("Отредактируйте объявление: Продам НРГ-500 за 45кк")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,414))
		if imgui.Button(u8"Ответ##14") then
				sampSendChat("Правильный ответ: Продам м/ц марки НРГ-500. Цена: 45млн.$")
		end
		if imgui.Button(u8"Набор в семью") then
				sampSendChat("Отредактируйте объявление: Набор в семью Nazvanie ждём у маяка")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,440))
		if imgui.Button(u8"Ответ##15") then
				sampSendChat("Правильный ответ: Семья Nazvanie ищет родственников. Ждём у маяка")
		end
		if imgui.Button(u8"Куплю дом в гетто за 3кк") then
				sampSendChat("Отредактируйте объявление: Куплю дом в гетто за 3кк")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,466))
		if imgui.Button(u8"Ответ##16") then
				sampSendChat("Правильный ответ: Куплю дом в опасном районе. Бюджет: 3.000.000$")
		end
		if imgui.Button(u8"Продам скин 123") then
				sampSendChat("Отредактируйте объявление: Продам скин 123")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,492))
		if imgui.Button(u8"Ответ##17") then
				sampSendChat("Правильный ответ: Продам одежду с биркой 123. Цена: договорная")
		end
		if imgui.Button(u8"Куплю скин конора") then
				sampSendChat("Отредактируйте объявление: Куплю скин конора за 7кк")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,518))
		if imgui.Button(u8"Ответ##18") then
				sampSendChat("Правильный ответ: Куплю одежду пошива Конор. Бюджет: 7.000.000$")
		end
		if imgui.Button(u8"Продам булку тт") then
				sampSendChat("Отредактируйте объявление: Продам булку тт ")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,544))
		if imgui.Button(u8"Ответ##50") then
				sampSendChat("Правильный ответ: Продам а/м марки Буллет с пакетом Твин-Турбо. Цена: договорная")
		end
		imgui.SameLine()
		imgui.Spacing()
		imgui.SameLine()
		imgui.Spacing()
		imgui.SameLine()
		imgui.Spacing()
		imgui.SameLine()
		--imgui.VerticalSeparator()
		imgui.Spacing()
		imgui.SameLine()
		imgui.SetCursorPos(imgui.ImVec2(242,76))
		if imgui.Button(u8"Продам трейлер") then
				sampSendChat("Отредактируйте объявление: Продам трейлер")
		end
			imgui.SetCursorPos(imgui.ImVec2(405,76))
		if imgui.Button(u8"Ответ##20") then
				sampSendChat("Правильный ответ: Продам дом на колёсах. Цена: договорная")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,102))
		if imgui.Button(u8"Куплю мод Химик") then
				sampSendChat("Отредактируйте объявление: Куплю модификацию Химик")
		end
			imgui.SetCursorPos(imgui.ImVec2(405,102))
		if imgui.Button(u8"Ответ##21") then
				sampSendChat("Правильный ответ: Куплю костюм Химик. Бюджет: свободный")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,128))
		if imgui.Button(u8"Продам дом в ФК") then
				sampSendChat("Отредактируйте объявление: Продам дом в ФК")
		end
			imgui.SetCursorPos(imgui.ImVec2(405,128))
		if imgui.Button(u8"Ответ##22") then
				sampSendChat("Правильный ответ: Продам дом в г.Форт-Карсон. Цена: договорная")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,154))
		if imgui.Button(u8"Обмен машинами") then
				sampSendChat("Отредактируйте объявление: Обменяю машину Булка на машину Туризмо")
		end
			imgui.SetCursorPos(imgui.ImVec2(405,154))
		if imgui.Button(u8"Ответ##23") then
				sampSendChat("Правильный ответ: Обменяю а/м марки Буллет на а/м марки Туризмо. Доплата: договорная")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,180))
		if imgui.Button(u8"Продам м/ц ПСЖ") then
				sampSendChat("Отредактируйте объявление: Продам м/ц ПСЖ-600")
		end
			imgui.SetCursorPos(imgui.ImVec2(405,180))
		if imgui.Button(u8"Ответ##24") then
				sampSendChat("Правильный ответ: Продам м/ц марки ПСЖ-600. Цена: договорная")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,206))
		if imgui.Button(u8"Куплю Маверик 24 кк") then
				sampSendChat("Отредактируйте объявление: Куплю Маверик 24 кк")
		end
			imgui.SetCursorPos(imgui.ImVec2(405,206))
		if imgui.Button(u8"Ответ##25") then
				sampSendChat("Правильный ответ: Куплю в/т марки Маверик. Бюджет: 24.000.000$")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,232))
		if imgui.Button(u8"Пиар 165 бара") then
				sampSendChat("Отредактируйте объявление: /vr В баре №165 около ЦР в ЛС ставки до 1.ООО.ООО$. Ждём тебя!")
		end
			imgui.SetCursorPos(imgui.ImVec2(405,232))
		if imgui.Button(u8"Ответ##26") then
				sampSendChat("Правильный ответ: Работает Бар в г.Лос-Сантос около Центрального рынка. Ждём всех")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,258))
		if imgui.Button(u8"Продам закусь в лв 100кк") then
				sampSendChat("Отредактируйте объявление: Продам закусь в ЛВ 100кк")
		end
			imgui.SetCursorPos(imgui.ImVec2(405,258))
		if imgui.Button(u8"Ответ##27") then
				sampSendChat("Правильный ответ: Продам б/з Закусочная в г.Лас-Вентурас. Цена: 100.000.000$, либо отказ: уточните город")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,284))
		if imgui.Button(u8"Продам магазин оружия") then
				sampSendChat("Отредактируйте объявление: Продам магазин оружия в ЛВ звоните")
		end
			imgui.SetCursorPos(imgui.ImVec2(405,284))
		if imgui.Button(u8"Ответ##28") then
				sampSendChat("Правильный ответ: Продам б/з АММО в г.Лас-Вентурас. Цена: договорная")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,310))
		if imgui.Button(u8"Продам Дилдо") then
				sampSendChat("Отредактируйте объявление: Продам дилдо за 65к")
		end
			imgui.SetCursorPos(imgui.ImVec2(405,310))
		if imgui.Button(u8"Ответ##29") then
				sampSendChat("Правильный ответ: Продам а/с Резиновая игрушка. Цена: 65.000$")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,336))
		if imgui.Button(u8"Продам Самсунг") then
				sampSendChat("Отредактируйте объявление: Продам Самсунг Галакси С10 за 1кк")
		end
			imgui.SetCursorPos(imgui.ImVec2(405,336))
		if imgui.Button(u8"Ответ##30") then
				sampSendChat("Правильный ответ: Продам м/т Самсунг Галакси С10. Цена: 1.000.000$")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,362))
		if imgui.Button(u8"Продам симку 1414194") then
				sampSendChat("Отредактируйте объявление: Продам симку 1414194")
		end
			imgui.SetCursorPos(imgui.ImVec2(405,362))
		if imgui.Button(u8"Ответ##31") then
				sampSendChat("Правильный ответ: Продам сим-карту формата АБ-АБ-АВБ. Цена: договорная")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,388))
		if imgui.Button(u8"Ищу друга(дискорд)") then
				sampSendChat("Отредактируйте объявление: Ищу другда с майкой Дискорд")
		end
			imgui.SetCursorPos(imgui.ImVec2(405,388))
		if imgui.Button(u8"Ответ##32") then
				sampSendChat("Правильный ответ: Отказ. Не рекламируем поиск людей с майкой дискорд. ")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,414))
		if imgui.Button(u8"Собес СМИ ЛВ") then
				sampSendChat("Отредактируйте объявление: Собес СМИ ЛВ")
		end
			imgui.SetCursorPos(imgui.ImVec2(405,414))
		if imgui.Button(u8"Ответ##33") then
				sampSendChat("Правильный ответ: Проходит собеседование в Радиоцентр г.Лас-Вентурас. Ждем в холле")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,440))
		if imgui.Button(u8"Собес в ФБР") then
				sampSendChat("Отредактируйте объявление: Собес в ФБР")
		end
			imgui.SetCursorPos(imgui.ImVec2(405,440))
		if imgui.Button(u8"Ответ##34") then
				sampSendChat("Правильный ответ: Отказ. Собеседование в ФБР никогда не проходят.")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,466))
		if imgui.Button(u8"Набор в Ацтек") then
				sampSendChat("Отредактируйте объявление: Набор в Ацтек")
		end
			imgui.SetCursorPos(imgui.ImVec2(405,466))
		if imgui.Button(u8"Ответ##35") then
				sampSendChat("Правильный ответ: Идет набор в ФК Ацтек. Ждём на районе")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,492))
		if imgui.Button(u8"Продам бронзу по 8к") then
				sampSendChat("Отредактируйте объявление: Продам бронзу по 8к")
				end
				imgui.SetCursorPos(imgui.ImVec2(405,492))
		if imgui.Button(u8"Ответ##36") then
				sampSendChat("Правильный ответ: Продам р/с бронзовая руда. Цена за штуку: 8.000$")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,518))
		if imgui.Button(u8"Продам шашку таксиста") then
				sampSendChat("Отредактируйте объявление: Продам шашку таксиста за 25кк")
				end
				imgui.SetCursorPos(imgui.ImVec2(405,518))
		if imgui.Button(u8"Ответ##37") then
				sampSendChat("Правильный ответ: Продам шашку таксиста. Цена: 25.000.000$")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,544))
						if imgui.Button(u8"Доп. Ищу собачку") then
				sampSendChat("Отредактируйте объявление: Ищу собачку по кличке Александр Твикс")
		end
				imgui.SetCursorPos(imgui.ImVec2(242,570))
		if imgui.Button(u8"Обмен аксами") then
				sampSendChat("Отредактируйте объявление: Обменяю Кешу на плечу +8 на любой акс +8")
		end
				imgui.SetCursorPos(imgui.ImVec2(405,570))
		if imgui.Button(u8"Ответ##19") then
				sampSendChat("Правильный ответ: Отказ. Не рекламируем обмен а/с")
		end
		imgui.SetCursorPos(imgui.ImVec2(405,544))
		if imgui.Button(u8"Ответ##555") then
				sampSendChat("Правильный ответ: Отказ. Не рекламируем поиск животных.")
		end
		imgui.SetCursorPos(imgui.ImVec2(5,569))
		if imgui.Button(u8"Доп. Продам ларьцы") then
		sampSendChat("Отредактируйте объявление: Продам ларцы с премией по 450к")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,569))
		if imgui.Button(u8"Ответ##51") then
				sampSendChat("Правильный ответ: Продам Ларец с премией. Цена: 450.000$")
		end	
		if imgui.Button(u8"Продам Super car box") then
		sampSendChat("Отредактируйте объявление: Продам Super car box по 1кк ")
		end 
		imgui.SetCursorPos(imgui.ImVec2(178,595))
		if imgui.Button(u8"Ответ##52") then
				sampSendChat("Правильный ответ: Продам Ларец с автомобилем. Цена: 1.000.000$")
		end
	end
	
	if imgui.CollapsingHeader(u8'Проверка Устава СМИ') then
	local ex_pos = imgui.GetCursorPos()
	if imgui.Button(u8"Готов?##2") then
			lua_thread.create(function()
				sampSendChat("Вы готовы сдать Устав СМИ?")
				wait(1000)
				sampSendChat("/time")
			end)
		end
	imgui.SameLine()
	if imgui.Button(u8"Верно!##2") then
		sampSendChat("Верно!")
		end
		imgui.SameLine()
		if imgui.Button(u8"Неверно!##2") then
		sampSendChat("Неверно!")
		end
		imgui.SameLine()
		if imgui.Button(u8"Сдал!##2") then
		sampSendChat("Поздравляю! Вы сдали Устав СМИ!")
		end
		imgui.SameLine()
		if imgui.Button(u8"Не сдал!##2") then
		sampSendChat("К сожалению вы не сдали Устав!!")
		end
		imgui.SameLine()
		if imgui.Button(u8"/time##2") then
		sampSendChat("/time")
		end
		imgui.Separator()		
		if imgui.Button(u8"Рабочий день в будние дни") then
		sampSendChat("Во сколько начинается-заканчивается рабочий день в будние дни?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 28))
		if imgui.Button(u8"Ответ##36") then
		sampSendChat("Правильный ответ: Начинается в 10:00 и заканчивается в 20:00")
		end
		if imgui.Button(u8"Рабочий день в выходные дни") then
		sampSendChat("Во сколько начинается-заканчивается рабочий день в выходные дни?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 52))
		if imgui.Button(u8"Ответ##37") then
		sampSendChat("Правильный ответ: Начинается в 10:00 и заканчивается в 19:00")
		end
		if imgui.Button(u8"Обеденный перерыв в будние дни") then
		sampSendChat("Во сколько начинается-заканчивается обеденный перерыв в будние дни?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 76))
		if imgui.Button(u8"Ответ##38") then
		sampSendChat("Правильный ответ: Начинается в 15:00 и заканчивается в 16:00")
		end
		if imgui.Button(u8"Обеденный перерыв в выходные дни") then
		sampSendChat("Во сколько начинается-заканчивается обеденный перерыв в выходные дни?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 100))
		if imgui.Button(u8"Ответ##39") then
		sampSendChat("Правильный ответ: Начинается в 15:00 и заканчивается в 16:00")
		end
		if imgui.Button(u8"Ночная смена в будние дни") then
		sampSendChat("Во сколько начинается-заканчивается ночная смена в будние дни?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 124))
		if imgui.Button(u8"Ответ##40") then
		sampSendChat("Правильный ответ: Начинается в 20:01 и заканчивается в 9:59")
		end
		if imgui.Button(u8"Ночная смена в выходные дни") then
		sampSendChat("Во сколько начинается-заканчивается ночная смена в выходные дни?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 148))
		if imgui.Button(u8"Ответ##41") then
		sampSendChat("Правильный ответ: Начинается в 19:01 и заканчивается в 9:59")
		end
		if imgui.Button(u8"Воздушные транспортные средства") then
		sampSendChat("С какой должности можно использовать воздушные транспортные средства?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 172))
		if imgui.Button(u8"Ответ##42") then
		sampSendChat("Правильный ответ: разрешается использовать с должности Режиссёр")
		end
		if imgui.Button(u8"Легковые автомобили") then
		sampSendChat("С какой должности разрешено использовать легковые автомобили?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 196))
		if imgui.Button(u8"Ответ##43") then
		sampSendChat("Правильный ответ: разрешается использовать с должности Ведущий")
		end
		if imgui.Button(u8"Служебный фургон") then
		sampSendChat("С какой должности разрешено использовать служебный фургон?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 220))
		if imgui.Button(u8"Ответ##44") then
		sampSendChat("Правильный ответ: разрешается использовать с должности Журналист")
		end
		if imgui.Button(u8"Оружие без лицензии") then
		sampSendChat("Разрешено ли носить оружие без лицензии?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 244))
		if imgui.Button(u8"Ответ##45") then
		sampSendChat("Правильный ответ: Запрещено! Наказывается выговором.")
		end
		if imgui.Button(u8"Наркотики") then
		sampSendChat("Разрешено ли носить наркотические средства?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 268))
		if imgui.Button(u8"Ответ##46") then
		sampSendChat("Правильный ответ: Запрещено! Наказывается увольнением.")
		end
		if imgui.Button(u8"Оружие") then
		sampSendChat("Разрешено ли использовать оружие на работе?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 292))
		if imgui.Button(u8"Ответ##47") then
		sampSendChat("Правильный ответ: Запрещено! Наказывается увольнением.")
		end
		if imgui.Button(u8"Правила сна") then
		sampSendChat("Какая норма сна для сотрудников?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 316))
		if imgui.Button(u8"Ответ##48") then
		sampSendChat("Правильный ответ: В неположеном месте не более 5 минут, в месте для сна не более 10 минут")
		end
		if imgui.Button(u8"С какой должности отпуск") then
		sampSendChat("С какой должности можно брать отпуск?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 340))
		if imgui.Button(u8"Ответ##49") then
		sampSendChat("Правильный ответ: с должности Ведущий")
		end --
		if imgui.Button(u8"Что будет за плагиат?") then
		sampSendChat("Что будет вам за плагиат в ваших работах?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 364))
		if imgui.Button(u8"Ответ##50") then
		sampSendChat("Правильный ответ: черный список Средства Массовой Инормации.")
		end
		if imgui.Button(u8"Что будет за субординацию?") then
		sampSendChat("Что будет вам за не соблюдение субординации с старшим составом?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 388))
		if imgui.Button(u8"Ответ##51") then
		sampSendChat("Правильный ответ: Выговор.")
		end
		if imgui.Button(u8"Выпрашивание должности") then
		sampSendChat("Что будет вам за выпрашивание должноти?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 412))
		if imgui.Button(u8"Ответ##52") then
		sampSendChat("Правильный ответ: Выговор.")
		end
		if imgui.Button(u8"Находится на тер. воен базы") then
		sampSendChat("Что будет вам за нахождение на терретории военных баз?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 436))
		if imgui.Button(u8"Ответ##53") then
		sampSendChat("Правильный ответ: увольнение.")
		end
		if imgui.Button(u8"Нахождение на ЦР в форме") then
		sampSendChat("Можно ли прогуливать рабочий день, находиться вне радиоцентра без причины (в форме, без нее)? ")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 250, ex_pos.y + 460))
		if imgui.Button(u8"Ответ##54") then
		sampSendChat("Правильный ответ: Нелья. Прогул в форме наказывается увольнением, без формы - выговором")
		end
		end
		if imgui.CollapsingHeader(u8'Проверка Правил проведения эфиров') then
	local ex_pos = imgui.GetCursorPos()
	if imgui.Button(u8"Готовы##3") then
			lua_thread.create(function()
				sampSendChat("Вы готовы сдать ППЭ?")
				wait(1000)
				sampSendChat("/time")
			end)
		end
	imgui.SameLine()
	if imgui.Button(u8"Верно!##3") then
		sampSendChat("Верно!")
		end
		imgui.SameLine()
		if imgui.Button(u8"Неверно!##3") then
		sampSendChat("Неверно!")
		end
		imgui.SameLine()
		if imgui.Button(u8"Сдал!##3") then
		sampSendChat("Поздравляю! Вы успешно сдали ППЭ!")
		end
		imgui.SameLine()
		if imgui.Button(u8"Не сдали!##3") then
		sampSendChat("К сожалению вы не сдали ППЭ!")
		end
		imgui.SameLine()
		if imgui.Button(u8"/time##3") then
		sampSendChat("/time")
		end
		imgui.Separator()		
		if imgui.Button(u8"На какое время можно занимать эфиры") then
		sampSendChat("На какое время можно занимать эфиры?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 28))
		if imgui.Button(u8"Ответ##60") then
		sampSendChat("Правильный ответ: можно эфиры можно на 05, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55 минут каждого часа.")
		end
		if imgui.Button(u8"Можно ли занимать эфир на час вперёд") then
		sampSendChat("Можно ли занимать эфир на час вперёд? Допустим сейчас 10:05, можите ли вы занять на 11:05?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 52))
		if imgui.Button(u8"Ответ##666") then
		sampSendChat("Правильный ответ: можно, но больше часа уже нельзя.")
		end
		if imgui.Button(u8"Интервал между эфиром собеседование") then
		sampSendChat("Какой интервал между эфиром собеседование?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 76))
		if imgui.Button(u8"Ответ##61") then
		sampSendChat("Правильный ответ: между эфиром собеседование интервал 10 минут")
		end
		if imgui.Button(u8"Интервал между интерактивным эфиром") then
		sampSendChat("Какой интервал между интерактивным эфиром?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 100))
		if imgui.Button(u8"Ответ##62") then
		sampSendChat("Правильный ответ: между интерактивным эфиром интервал 10 минут")
		end
		if imgui.Button(u8"Интервал между развлекательным эфиром") then
		sampSendChat("Какой интервал между развлекательным эфиром?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 124))
		if imgui.Button(u8"Ответ##63") then
		sampSendChat("Правильный ответ: между развлекательным эфиром интервал 10 минут")
		end
		if imgui.Button(u8"Минимальное время интеракривного") then
		sampSendChat("Какое минимальное время проведения интерактивного эфира?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 148))
		if imgui.Button(u8"Ответ##64") then
		sampSendChat("Правильный ответ: минимальное время проведение 20 минут!")
		end
		if imgui.Button(u8"Минимальное время экстренного эфира") then
		sampSendChat("Какое минимальное время проведения экстренного эфира?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 172))
		if imgui.Button(u8"Ответ##65") then
		sampSendChat("Правильный ответ: минимальное время проведение 1 минута!")
		end
		if imgui.Button(u8"Минимальное время собеседования") then
		sampSendChat("Какое минимальное время проведения эфира собеседования?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 196))
		if imgui.Button(u8"Ответ##66") then
		sampSendChat("Правильный ответ: минимальное время проведение 1 минута!")
		end
		if imgui.Button(u8"Через сколько можно начать эфир") then
		sampSendChat("Вот допустим сейчас 10:00, и у вас должен начатся эфир, через сколько вы можите его начать?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 220))
		if imgui.Button(u8"Ответ##67") then
		sampSendChat("Правильный ответ: для того чтобы начать эфир у вас есть 2-3 минуты!")
		end
		if imgui.Button(u8"Приз в развлекательных") then
		sampSendChat("Какой минимальный и максимальный приз в развлекательном эфире?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 244))
		if imgui.Button(u8"Ответ##68") then
		sampSendChat("Правильный ответ: Минимальный: 30.000$, максимальный 500.000$")
		end
		if imgui.Button(u8"Что нужно сделать перед началом эфира") then
		sampSendChat("Что нужно сделать перед тем, как начать эфир?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 268))
		if imgui.Button(u8"Ответ##69") then
		sampSendChat("Нужно занять эфир в Спец. Рации дискорд, сообщить в депортаменте о начале эфира.")
		end
		if imgui.Button(u8"Виды эфира") then
		sampSendChat("Сколько есть видов эфиров и перечислите их")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 292))
		if imgui.Button(u8"Ответ##70") then
		lua_thread.create(function()
		sampSendChat("Есть 8 видов эфиров: интерактивный, развлекательный, познавательный,")
		wait(1000)
		sampSendChat("интервью, экстренный, рекламный, новостной.")
		end)
		end
		if imgui.Button(u8"Сколько должны выехать на место событий") then
		sampSendChat("Сколько сотрудников должны выехать на место событий?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 316))
		if imgui.Button(u8"Ответ##71") then
		sampSendChat("Как минумум два сторудника.")
		end
		if imgui.Button(u8"Сколько ждать после отката эфира?") then
		sampSendChat("Сколько должен ждать сотрудник, который отменил эфир?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 340))
		if imgui.Button(u8"Ответ##72") then
		sampSendChat("30 минут.")
		end
		if imgui.Button(u8"Сколько ждать после отката эфира?") then
		sampSendChat("Разрешено ли забивать два эфира с одного радиоцентра одновременно, пока первый эфир не провели?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 364))
		if imgui.Button(u8"Ответ##73") then
		sampSendChat("Запрещено!")
		end
		if imgui.Button(u8"Время проведения рекламных эфиров") then
		sampSendChat("Со сколько до скольки запрещено проводит рекламные эфиры?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 388))
		if imgui.Button(u8"Ответ##74") then
		sampSendChat("с 23:00 до 11:00.")
		end
		if imgui.Button(u8"Критерии для интервью") then
		sampSendChat("Какие минимальные критерии для взятия интервью?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 412))
		if imgui.Button(u8"Ответ##75") then
		lua_thread.create(function()
		sampSendChat("Интервью проводится с лидером/заместителем фракции")
		wait(1000)
		sampSendChat("либо же с известными личностями (30 и больше лет жизни в штате)")
		end)
		end
		end
		if imgui.CollapsingHeader(u8'Проверка Правил Редактирования Газет') then
	local ex_pos = imgui.GetCursorPos()
	if imgui.Button(u8"Готовы?##4") then
	lua_thread.create(function()
				sampSendChat("Вы готовы сдать ПРГ?")
				wait(1000)
				sampSendChat("/time")
		end)
		end
	imgui.SameLine()
	if imgui.Button(u8"Верно##4") then
		sampSendChat("Верно!")
		end
		imgui.SameLine()
		if imgui.Button(u8"Неверно##4") then
		sampSendChat("Неверно!")
		end
		imgui.SameLine()
		if imgui.Button(u8"Сдал##4") then
		sampSendChat("Поздравляю вы сдали Правила Редактирования Газет!")
		end
		imgui.SameLine()
		if imgui.Button(u8"Не сдал##4") then
		sampSendChat("К сожалению вы не сдали Правила Редактирования Газет! Подучите еще")
		end
		imgui.SameLine()
		if imgui.Button(u8"/time##4") then
		sampSendChat("/time")
		end
		imgui.Separator()	
			if imgui.Button(u8"Создание газет должность") then
				sampSendChat("С какой должность разрешено создавать газеты?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 28))
		if imgui.Button(u8"Ответ##1001") then
				sampSendChat("Правильный ответ: с должности Главного Редактора и выше.")
		end
			if imgui.Button(u8"Редактировать с какого ранга") then
				sampSendChat("С какой должности разрешено редактировать газеты?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 52))
		if imgui.Button(u8"Ответ##1002") then
				sampSendChat("Правильный ответ: с должности Журналист")
		end
		if imgui.Button(u8"Продавать газеты ранг") then
				sampSendChat("С какой должности разрешено продавать газеты?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 76))
		if imgui.Button(u8"Ответ##1003") then
				sampSendChat("Правильный ответ: с должности практикант")
		end
		if imgui.Button(u8"Можно ли размещать киоск на дороге?") then
				sampSendChat("Разрешено ли размещать киоск с газетами на дорогу??")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 100))
		if imgui.Button(u8"Ответ##1004") then
				sampSendChat("Правильный ответ: Запрещено.")
		end
		if imgui.Button(u8"Можно ли в интах размещать киоск?") then
				sampSendChat("Разрешено ли размещать киоск внутри здания?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 124))
		if imgui.Button(u8"Ответ##1005") then
				sampSendChat("Правильный ответ: Запрещено.")
		end
		if imgui.Button(u8"Можно ли стоять на киоске?") then
				sampSendChat("Разрешено ли стоять на киоске?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 148))
		if imgui.Button(u8"Ответ##1006") then
				sampSendChat("Правильный ответ: Запрещено")
	
		end
		if imgui.Button(u8"Минимум сколько газет в киоске") then
				sampSendChat("Минимум сколько газет должен содержать киоск? ")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 172))
		if imgui.Button(u8"Ответ##1007") then
				sampSendChat("Правильный ответ: Минимум 3 газеты.")
		end
		if imgui.Button(u8"Виды газет") then
				sampSendChat("Сколько есть видов газет и назовите их.")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 196))
		if imgui.Button(u8"Ответ##1008") then
				sampSendChat("Правильный ответ: Есть 4 вида газет: информационные, развлекательные, рекламные газеты и жёлтая пресса.")
		end
		if imgui.Button(u8"На каком языке название авто в газете?") then
				sampSendChat("На каком языке название авто в газете?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 220))
		if imgui.Button(u8"Ответ##1009") then
				sampSendChat("Правильный ответ: На англисйком языке.")
		end
		if imgui.Button(u8"Что такое желтая пресса?") then
				sampSendChat("Что из себя представляет желтая пресса?")
		end
		imgui.SetCursorPos(imgui.ImVec2(200, 20))
		imgui.SetCursorPos(imgui.ImVec2(ex_pos.x + 260, ex_pos.y + 244))
		if imgui.Button(u8"Ответ##1010") then
				sampSendChat("Правильный ответ: провокационные газеты, создающиеся с целью задеть кого-то.")
		end
	end
		
	imgui.End()
end
