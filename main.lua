local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local carDB = {
    ["ОКА 1111"] = "легковой", ["ВАЗ-2104"] = "легковой", ["ВАЗ-2106"] = "легковой", ["ВАЗ-2109"] = "легковой", ["ВАЗ-2112"] = "легковой", ["LADA Priora"] = "легковой", 
    ["Chevrolet Lacetti"] = "легковой", ["LADA Largus"] = "легковой", ["LADA Vesta"] = "легковой", ["LADA Niva Travel"] = "легковой", ["УАЗ Патриот"] = "легковой", 
    ["Toyota Camry 2007"] = "легковой", ["Toyota Camry XV55"] = "легковой", ["Hyundai Solaris 2011"] = "легковой", ["Nissan Qashqai"] = "легковой", 
    ["Haval F7"] = "легковой", ["Kia Sorento 2021"] = "легковой", ["Mercedes-Benz C320"] = "легковой", ["Toyota Land Cruiser 200"] = "легковой", 
    ["Volkswagen Golf"] = "легковой", ["Volkswagen Jetta"] = "легковой", ["Audi 100"] = "легковой", ["Nissan 370Z"] = "легковой", ["Volkswagen Touareg"] = "легковой",
    ["Kia Rio 2020"] = "такси", ["Toyota Camry XV70"] = "такси", ["Skoda Octavia A7"] = "такси",
    ["Ford Transit Yandыx"] = "коммерческий", ["ГАЗель NN"] = "коммерческий", ["ГАЗон Next"] = "грузовой", ["Камаз 6520"] = "грузовой", 
    ["MAN TGL"] = "грузовой", ["Scania R620"] = "грузовой", ["КамАЗ - 6282"] = "автобус", ["ГАЗ Next"] = "автобус", ["Паз Vector"] = "автобус", 
    ["ПАЗ - 3205"] = "автобус", ["ГАЗ Next Microbus"] = "автобус", ["Ford Transit МЧС"] = "мчс", ["Камаз АЦ-40 4х4"] = "мчс", ["Урал 4320"] = "мчс", 
    ["Камаз АЦ-40"] = "мчс", ["MAN TGA"] = "мчс", ["Ford Transit | СМП"] = "смп", ["ГАЗель NEXT | Реанимация"] = "смп", ["Ford Transit | Реанимация"] = "смп", 
    ["ГАЗель NEXT | СМП"] = "смп", ["Audi A4 B8"] = "премиум", ["Audi A6 C7"] = "премиум", ["Audi RS6 Avant"] = "премиум", ["Mercedes Benz E63 AMG"] = "премиум", 
    ["BMW M5 F90"] = "премиум", ["BMW M4 F82"] = "премиум", ["BMW X5M"] = "премиум", ["Mercedes AMG GT 63s"] = "премиум", ["Mercedes Benz E63"] = "премиум", 
    ["Mercedes-Benz G63 «Гелик»"] = "премиум", ["Mercedes-Benz W206"] = "премиум", ["BMW G30"] = "премиум", ["Toyota Land Cruiser 300"] = "премиум", ["Tesla Model S P90D"] = "премиум"
}

local cMap = {
    ["black"] = "черная", ["carbon"] = "угольно-черная", ["white"] = "белая", ["snow"] = "белоснежная", ["gray"] = "серая", ["grey"] = "серая", 
    ["silver"] = "серебристая", ["slate"] = "графитовая", ["red"] = "красная", ["crimson"] = "бордовая", ["blue"] = "синяя", ["navy"] = "темно-синяя", 
    ["cyan"] = "голубая", ["green"] = "зеленая", ["lime"] = "салатовая", ["yellow"] = "желтая", ["orange"] = "оранжевая", ["gold"] = "золотистая"
}

local selModel, cMark, cColor, cPlate, cDist = nil, "ТС", "неизвестного цвета", "без номеров", 999
local esp = nil

local function getDetails(m)
    if not m then return "ТС", "неизвестного цвета", "без номеров" end
    local ln, mk, col, pl = string.lower(m.Name), "Иномарка", "серая", "Х777ХХ_77"
    for k,_ in pairs(carDB) do if string.find(ln, string.lower(k)) or string.find(string.lower(k), ln) then mk = k break end end
    for _,p in ipairs(m:GetDescendants()) do
        if p:IsA("BasePart") and (string.find(string.lower(p.Name), "body") or string.find(string.lower(p.Name), "paint")) then
            local bn = string.lower(p.BrickColor.Name)
            for e,r in pairs(cMap) do if string.find(bn, e) then col = r break end end
        end
    end
    for _,o in ipairs(m:GetDescendants()) do
        if (o:IsA("TextLabel") or o:IsA("TextBox")) and (string.find(string.lower(o.Name), "plate") or string.find(string.lower(o.Name), "number")) then
            local cl = string.match(o.Text, "^%s*(.-)%s*$")
            if cl and cl ~= "" and #cl >= 2 then pl = cl break end
        end
    end
    return mk, col, pl
end

-- Безопасная функция отправки без использования VirtualUser
local function safeSend(text)
    local textChatService = game:GetService("TextChatService")
    if textChatService and textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = textChatService.TextChannels:FindFirstChild("RBXGeneral")
         if channel then 
            channel:SendAsync(text) 
         end
    else
        -- Запасной скрытый метод для старых версий чата
        local sayMessage = game:GetService("ReplicatedStorage"):FindFirstChild("SayMessageRequest", true)
        if sayMessage and sayMessage:IsA("RemoteEvent") then
            sayMessage:FireServer(text, "All")
        end
    end
end

local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "DPS_Menu"
if syn and syn.protect_gui then syn.protect_gui(sg) end

local f = Instance.new("Frame", sg)
f.Size, f.BackgroundColor3, f.Visible = UDim2.new(0, 140, 0, 80), Color3.fromRGB(30, 30, 35), false
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

local b1 = Instance.new("TextButton", f)
b1.Size, b1.Position, b1.BackgroundColor3, b1.TextColor3, b1.Text, b1.Font, b1.TextSize = UDim2.new(1, -10, 0, 28), UDim2.new(0, 5, 0, 8), Color3.fromRGB(0, 70, 180), Color3.fromRGB(255, 255, 255), "🛑 ОСТАНОВИТЬ", Enum.Font.SourceSansBold, 13
Instance.new("UICorner", b1).CornerRadius = UDim.new(0, 4)

local b2 = Instance.new("TextButton", f)
b2.Size, b2.Position, b2.BackgroundColor3, b2.TextColor3, b2.Text, b2.Font, b2.TextSize = UDim2.new(1, -10, 0, 28), UDim2.new(0, 5, 0, 42), Color3.fromRGB(150, 40, 40), Color3.fromRGB(255, 255, 255), "❌ ВЫЙТИ", Enum.Font.SourceSansBold, 13
Instance.new("UICorner", b2).CornerRadius = UDim.new(0, 4)

local lbl = Instance.new("TextLabel", sg)
lbl.Size, lbl.Position, lbl.BackgroundColor3, lbl.TextColor3, lbl.Font, lbl.TextSize, lbl.Text = UDim2.new(0, 380, 0, 30), UDim2.new(0.5, -190, 0, 10), Color3.fromRGB(20, 20, 25), Color3.fromRGB(255, 255, 255), Enum.Font.SourceSansBold, 13, "ОБ ДПС: [Зажми Ctrl + Клик на авто]"
Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 6)

local m = localPlayer:GetMouse()
local tmp = nil

m.Button1Down:Connect(function()
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local t = m.Target
        local cm = t and t:FindFirstAncestorOfClass("Model")
        if cm and (cm:FindFirstChildOfClass("VehicleSeat") or cm.Parent:FindFirstChildOfClass("VehicleSeat")) then
            tmp = cm
            task.wait(0.05)
            f.Position = UDim2.new(0, m.X + 10, 0, m.Y + 10)
            f.Visible = true
        end
    end
end)

b1.MouseButton1Click:Connect(function()
    if tmp then
        selModel = tmp
        cMark, cColor, cPlate = getDetails(selModel)
        if esp then esp:Destroy() end
        esp = Instance.new("Highlight", selModel)
        esp.FillColor, esp.FillTransparency = Color3.fromRGB(0, 120, 255), 0.4
    end
    f.Visible = false
end)

b2.MouseButton1Click:Connect(function()
    selModel = nil
    if esp then esp:Destroy() esp = nil end
    lbl.Text = "ОБ ДПС: [Зажми Ctrl + Клик на авто]"
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    f.Visible = false
end)

RunService.Heartbeat:Connect(function()
    if selModel and (selModel.PrimaryPart or selModel:FindFirstChildOfClass("VehicleSeat")) then
        local ch = localPlayer.Character
        if ch and ch:FindFirstChild("HumanoidRootPart") then
            local tp = selModel.PrimaryPart or selModel:FindFirstChildOfClass("VehicleSeat")
            cDist = math.floor((ch.HumanoidRootPart.Position - tp.Position).Magnitude)
            if cDist <= 100 then
                lbl.Text = string.format("🎯 ЦЕЛИ СБЛИЖЕНИЯ | %s (%s) | %d м. [ДОСТУПЕН]", cMark, cPlate, cDist)
                lbl.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                lbl.Text = string.format("📡 ДАЛЬНИЙ ХВОСТ | %s (%s) | %d м. [ДАЛЕКО (>100м)]", cMark, cPlate, cDist)
                lbl.TextColor3 = Color3.fromRGB(255, 160, 60)
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, p)
    if p or not selModel or (cDist and cDist > 100) then return end
    local info = string.format("%s %s %s", cColor, cMark, cPlate)
    if i.KeyCode == Enum.KeyCode.F1 then safeSend("/do 1 законное требование Справа прижимай, " .. info)
    elseif i.KeyCode == Enum.KeyCode.F2 then safeSend("/do 2 законное требование Справа прижимай, " .. info)
    elseif i.KeyCode == Enum.KeyCode.F3 then safeSend("/do 3 законное требование Справа прижимай, " .. info)
    elseif i.KeyCode == Enum.KeyCode.F4 then safeSend("/do Предупреждение о стрельбе по колесам Справа прижимай, " .. info)
    end
end)
