-- Emote Wheel (Roblox-style circular) — 996 emotes
-- loadstring(game:HttpGet("URL"))()
if getgenv().__EmoteWheelLoaded then return end
getgenv().__EmoteWheelLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local InsertService = game:GetService("InsertService")

if not game:IsLoaded() then game.Loaded:Wait() end
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do task.wait(); LocalPlayer = Players.LocalPlayer end

local guiParent
pcall(function() guiParent = game:GetService("CoreGui") end)
if not guiParent then guiParent = LocalPlayer:WaitForChild("PlayerGui") end

local function SendNotify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Emote Wheel", Text = msg, Duration = 3
        })
    end)
end

-- Отключаем стандартное колесо эмоций Roblox
pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false) end)
pcall(function() StarterGui:SetCore("SetEmotesMenuEnabled", false) end)

local S = {
    wheelBg    = Color3.fromRGB(20, 16, 36),
    sectorNorm = Color3.fromRGB(28, 22, 48),
    sectorHov  = Color3.fromRGB(90, 50, 160),
    textMain   = Color3.fromRGB(235, 230, 255),
    textSoft   = Color3.fromRGB(165, 155, 200),
    stroke     = Color3.fromRGB(100, 70, 180),
    accent     = Color3.fromRGB(160, 90, 255),
    danger     = Color3.fromRGB(255, 75, 100),
    fav        = Color3.fromRGB(255, 200, 60),
    center     = Color3.fromRGB(14, 11, 28),
    centerText = Color3.fromRGB(200, 185, 240),
    pageBg     = Color3.fromRGB(30, 24, 52),
    loopOn     = Color3.fromRGB(255, 200, 60),
    loopOff    = Color3.fromRGB(165, 155, 200),
}

-- ========== ЭМОЦИИ ==========
local AllEmotes = {
    { name = "Salute", id = 3360689775 },
    { name = "Tilt", id = 3360692915 },
    { name = "Rthro Animation Package", id = 2510230574 },
    { name = "Applaud", id = 5915779043 },
    { name = "Oldschool Animation Pack", id = 5319900634 },
    { name = "Stylish Animation Pack", id = 619509955 },
    { name = "Robot Animation Pack", id = 619521311 },
    { name = "Shrug", id = 3576968026 },
    { name = "Toy Animation Pack", id = 973766674 },
    { name = "Stadium", id = 3360686498 },
    { name = "Hello", id = 3576686446 },
    { name = "Point2", id = 3576823880 },
    { name = "adidas Community Animation Pack", id = 123695349157584 },
    { name = "Monkey", id = 3716636630 },
    { name = "Curtsy", id = 4646306583 },
    { name = "Happy", id = 4849499887 },
    { name = "Cartoony Animation Package", id = 837009922 },
    { name = "Zombie Animation Pack", id = 619535091 },
    { name = "Bubbly Animation Package", id = 1018554245 },
    { name = "Mage Animation Package", id = 754635032 },
    { name = "Godlike", id = 3823158750 },
    { name = "Ninja Animation Package", id = 658830056 },
    { name = "Baby Queen - Bouncy Twirl", id = 14353423348 },
    { name = "Sleep", id = 4689362868 },
    { name = "Shy", id = 3576717965 },
    { name = "Bold Animation Pack by e.l.f.", id = 16744204409 },
    { name = "Wicked Popular Animation Pack", id = 135810009801094 },
    { name = "Baby Queen - Face Frame", id = 14353421343 },
    { name = "Floss Dance", id = 5917570207 },
    { name = "Hero Landing", id = 5104377791 },
    { name = "adidas Sports Animation Pack", id = 18538133604 },
    { name = "Yungblud Happier Jump", id = 15610015346 },
    { name = "Superhero Animation Pack", id = 619527470 },
    { name = "Quiet Waves", id = 7466046574 },
    { name = "Baby Queen - Strut", id = 14353425085 },
    { name = "Bored", id = 5230661597 },
    { name = "Elder Animation Package", id = 892267099 },
    { name = "High Wave", id = 5915776835 },
    { name = "Vampire Animation Pack", id = 1113740510 },
    { name = "Alo Yoga Pose - Lotus Position", id = 12507097350 },
    { name = "Cower", id = 4940597758 },
    { name = "adidas aura animation pack", id = 140398319728398 },
    { name = "Catwalk Glam Animation Pack by e.l.f.", id = 104741822987331 },
    { name = "Baby Dance", id = 4272484885 },
    { name = "Celebrate", id = 3994127840 },
    { name = "Effortless Aura Pose", id = 101573394483995 },
    { name = "Levitation Animation Pack", id = 619541458 },
    { name = "V Pose - Tommy Hilfiger", id = 10214418283 },
    { name = "Mae Stephens - Piano Hands", id = 16553249658 },
    { name = "Werewolf Animation Pack", id = 1113750642 },
    { name = "Frosty Flair - Tommy Hilfiger", id = 10214406616 },
    { name = "Astronaut Animation Pack", id = 1090130630 },
    { name = "KATSEYE - Touch", id = 139021427684680 },
    { name = "Haha", id = 4102315500 },
    { name = "Cuco - Levitate", id = 15698511500 },
    { name = "Greatest", id = 3762654854 },
    { name = "No Boundaries Animation Pack by Walmart", id = 18755919175 },
    { name = "Sad", id = 4849502101 },
    { name = "TWICE Feel Special", id = 14900153406 },
    { name = "Olivia Rodrigo Head Bop", id = 15554010118 },
    { name = "Line Dance", id = 4049646104 },
    { name = "Secret Handshake Dance", id = 120642514156293 },
    { name = "💀MM2 Fake Dead", id = 132384701706046 },
    { name = "Show Dem Wrists - KSI", id = 7202898984 },
    { name = "Old Town Road Dance - Lil Nas X (LNX)", id = 5938394742 },
    { name = "Godly Aura fly pose idle", id = 76361248833307 },
    { name = "Confused", id = 4940592718 },
    { name = "Festive Dance", id = 15679955281 },
    { name = "Stylish Floating", id = 88425531063616 },
    { name = "Rat Dance", id = 98603994713783 },
    { name = "Chappell Roan HOT TO GO!", id = 79312439851071 },
    { name = "Side to Side", id = 3762641826 },
    { name = "Beckon", id = 5230615437 },
    { name = "TWICE LIKEY", id = 14900151704 },
    { name = "Knight Animation Package", id = 734325948 },
    { name = "Fast Hands", id = 4272351660 },
    { name = "hip sway", id = 80963950541052 },
    { name = "/e fly", id = 93511411593120 },
    { name = "HIPMOTION - Amaarae", id = 16572756230 },
    { name = "Dolphin Dance", id = 5938365243 },
    { name = "Popular", id = 71302743123422 },
    { name = "Jumping Wave", id = 4940602656 },
    { name = "Victory Dance", id = 15506503658 },
    { name = "Break Dance", id = 5915773992 },
    { name = "Dizzy", id = 3934986896 },
    { name = "Floating on clouds", id = 111426928948833 },
    { name = "🎃Pumpkin King👑", id = 105381637724646 },
    { name = "Sturdy Dance - Ice Spice", id = 17746270218 },
    { name = "Basketball Head", id = 107282826166809 },
    { name = "Twirl", id = 3716633898 },
    { name = "[BEST] It's Gangnam Style!", id = 104142334418357 },
    { name = "Zombie", id = 4212496830 },
    { name = "HOLIDAY Dance - Lil Nas X (LNX)", id = 5938396308 },
    { name = "Lush Life", id = 82727664018494 },
    { name = "Baby Queen - Air Guitar & Knee Slide", id = 14353417553 },
    { name = "Floating in Love 🥰", id = 97164262994588 },
    { name = "Amazon Unboxed Animation Pack", id = 117011755848398 },
    { name = "Shuffle", id = 4391208058 },
    { name = "Spiderman Hang", id = 108635834286627 },
    { name = "Sidekicks - George Ezra", id = 10370922566 },
    { name = "Big Guy - 🔥 Ice Spice x Spongebob", id = 107708114415320 },
    { name = "griddy", id = 129149402922241 },
    { name = "Tommy - Archer", id = 13823339506 },
    { name = "Bodybuilder", id = 3994130516 },
    { name = "Agree", id = 4849487550 },
    { name = "Nonchalant Sit", id = 85092320680319 },
    { name = "Floating", id = 139058906415119 },
    { name = "🕷️ Hornet's Spider Dance 🕷️", id = 74716792202343 },
    { name = "DARE - Gorillaz", id = 136648387080677 },
    { name = "Endless Aura Floating", id = 106708015414624 },
    { name = "Cute Feet Kicking", id = 78224683906191 },
    { name = "Power Blast", id = 4849497510 },
    { name = "Bone Chillin' Bop", id = 15123050663 },
    { name = "Skibidi Toilet - Titan Speakerman Laser Spin", id = 103102322875221 },
    { name = "SHAKE", id = 132367660388476 },
    { name = ":invisible me", id = 94292601332790 },
    { name = "Cute Kawaii Posing >-<", id = 94064805002669 },
    { name = "Gojo Floating Pose / The Honored One ", id = 103040723950430 },
    { name = "Baby Queen - Dramatic Bow", id = 14353419229 },
    { name = "[BEST] Chinese Military Dance Pose", id = 131258378669186 },
    { name = "Pirate Animation Package", id = 837023444 },
    { name = "Take The L ✅", id = 82405492529515 },
    { name = "Fashionable", id = 3576745472 },
    { name = "Nicki Minaj Starships", id = 15571540519 },
    { name = "WOOF BARK WOOF ", id = 88859617281337 },
    { name = "silly jumping spider dance", id = 89157328525577 },
    { name = "Hips Poppin' - Zara Larsson", id = 6797919579 },
    { name = "Moon Walk", id = 79127989560307 },
    { name = "NFL Animation Pack", id = 122757794615785 },
    { name = "Ghost Floating", id = 75911227509248 },
    { name = "Tornado", id = 82995540773684 },
    { name = "Cute kawaii girly idle Profile pose", id = 138515241510970 },
    { name = "Wake Up Call - KSI", id = 7202900159 },
    { name = "Disagree", id = 4849495710 },
    { name = "Hakari Dance", id = 122147154162464 },
    { name = "Metro Man arm swings", id = 136271269847411 },
    { name = "Boxing Punch - KSI", id = 7202896732 },
    { name = "Cute Sit	", id = 129575609080331 },
    { name = "Rodeo Dance - Lil Nas X (LNX)", id = 5938397555 },
    { name = "I  WANNA RUN AWAY", id = 135431679610889 },
    { name = "Tall Scary Creature", id = 79216795769647 },
    { name = "Sol de Janeiro - Samba", id = 16276506814 },
    { name = "T", id = 3576719440 },
    { name = "I Want Money", id = 89114994401113 },
    { name = "apple store girl (do you want me)", id = 86591723458333 },
    { name = "Tree", id = 4049634387 },
    { name = "Beauty Touchdown", id = 16303091119 },
    { name = "ACELERADA", id = 84204365810397 },
    { name = "HUGO Let's Drive!", id = 17360720445 },
    { name = "Nicki Minaj Boom Boom Boom", id = 15571538346 },
    { name = "★ curiously cute sitting pose", id = 76261461321661 },
    { name = "MJ - P.Y.T. Pretty Young Thing", id = 137234266130963 },
    { name = "The Weeknd Starboy Strut", id = 130245358716273 },
    { name = "Olivia Rodrigo Fall Back to Float", id = 15554016057 },
    { name = "Jumping Cheer", id = 5895009708 },
    { name = "z sturdy (actual original)", id = 120702604995324 },
    { name = "Spice Jersey Bounce", id = 126529053628312 },
    { name = "Possessed Glitcher", id = 106370760824973 },
    { name = "Sturdy Dance - Ice Spice [CHEAP]", id = 72333659132786 },
    { name = "Bubbly Sit", id = 112758073578333 },
    { name = "KATSEYE - Better in Denim (GAP)", id = 86184456144623 },
    { name = "Aura Fly Sitting", id = 72450410210932 },
    { name = "Fashion Roadkill", id = 73683655527605 },
    { name = "Lasso Turn - Tai Verdes", id = 7942972744 },
    { name = "Possessed", id = 102610758906338 },
    { name = "Samba", id = 6869813008 },
    { name = "Rock On", id = 5915782672 },
    { name = "TWICE - The Feels", id = 79194689807074 },
    { name = "♡ cute halloween magical witch idle pose", id = 96252923654843 },
    { name = "Dorky Dance", id = 4212499637 },
    { name = "Take Me Under - Zara Larsson", id = 6797938823 },
    { name = "TWICE - What Is Love", id = 91811386043367 },
    { name = "Cut Water Summer Dance!", id = 71825767065274 },
    { name = "cute sitting with legs out", id = 139076155588413 },
    { name = "Make You Mine", id = 97092824850945 },
    { name = "Hear Me Now", id = 133307355099075 },
    { name = "Flowing Breeze", id = 7466047578 },
    { name = "Become Tall", id = 74601470677586 },
    { name = "Nyan Nyan! ", id = 73796726960568 },
    { name = "Glow Motion Animation Pack", id = 122281742555667 },
    { name = "[BEST] Dougie (Everybody Loves Me)", id = 114756515400742 },
    { name = "✅ Obby Head - Emote", id = 122814100170962 },
    { name = "Emperor Of The Auraverse [[Aura]]", id = 133594786690861 },
    { name = "Koto Nai Meme Dance", id = 91927498467600 },
    { name = "Sweet Hug Pose V2 [MATCHING]", id = 79076692213299 },
    { name = "Feeling Cute", id = 112540347880956 },
    { name = "Race Car", id = 121936817462716 },
    { name = "Flex Walk", id = 15506506103 },
    { name = "Floating Idle animation", id = 117134539591727 },
    { name = "Floating Goddess (Matching Floating Adonis) 🖤!!", id = 106454952665088 },
    { name = "Get Sturdy", id = 127480853388432 },
    { name = "Spice On Floor", id = 126837474178236 },
    { name = "Caramelldansen (Caramell) Kawaii Dance", id = 97847706148165 },
    { name = "TV Time Dance", id = 75017857395637 },
    { name = "Floating", id = 70615023659736 },
    { name = "feelin myself sway", id = 74941409284905 },
    { name = "TYLA Chanel - Kpop Trendy Dance", id = 80341701361363 },
    { name = "Trip Out", id = 75483681450871 },
    { name = "Hype Boy - NewJeans", id = 122829513155529 },
    { name = "Dancin' Shoes - Twenty One Pilots", id = 7405123844 },
    { name = "Jamal Dance", id = 72213123467340 },
    { name = "Korean Greeting! (Annyeong / 안녕)", id = 135719167611495 },
    { name = "Scene Roblox Profile Pose", id = 108221503648290 },
    { name = "Team USA Breaking Emote", id = 18526338976 },
    { name = "Charming Cute Look Pose", id = 101275066718933 },
    { name = "kawai shy sit idle pose", id = 105933851371838 },
    { name = "Sit", id = 101743582461626 },
    { name = "Secret Handshake Dance 2 - Wicked Official", id = 134373057501582 },
    { name = "Spice Keep Bouncing", id = 121347449465835 },
    { name = "Orange Justice", id = 110064349530772 },
    { name = "Chinese Dance", id = 120605439830304 },
    { name = "Kid tantrum", id = 121911959295081 },
    { name = "Sturdy NYC Dance ", id = 122687759897103 },
    { name = "Floor Rock Freeze - Tommy Hilfiger", id = 10214411646 },
    { name = "SpiderMan Hanging Pose [Original]", id = 110511723808460 },
    { name = "[HOT🔥] Spinning Cat", id = 75739251269771 },
    { name = "NO HANDS", id = 95664256018756 },
    { name = "۶ৎ adorable dolly pose ", id = 89104845724058 },
    { name = "FF Push Up", id = 73630423562709 },
    { name = "Blue Top Rock", id = 101572357319427 },
    { name = "KATSEYE - GNARLY", id = 133685484220846 },
    { name = "Cute Pretty Girly Girl Fierce Slay Idle Pose", id = 135853357333509 },
    { name = "[AURA FARM] YN Wall Lean", id = 71556328869803 },
    { name = "Robot", id = 3576721660 },
    { name = "Belly Dance", id = 76700167742736 },
    { name = "Kissy Roblox Profile Pose", id = 73398162799786 },
    { name = "STURDY", id = 120302905807132 },
    { name = "Hype Boy - NewJeans", id = 105324347192111 },
    { name = "Springtrapped (Face Animated)", id = 125974779288821 },
    { name = "💀MM2 Fake Dead - 3", id = 79297779614324 },
    { name = "Uprise - Tommy Hilfiger", id = 10275057230 },
    { name = "⸸꒱ cute knee sit idle pose", id = 72753598082403 },
    { name = "♡: Kawaii Bouncy Anime Girl Dance [OG]", id = 130855166586798 },
    { name = "Panini Dance - Lil Nas X (LNX)", id = 5915781665 },
    { name = "Wall Aura Farm Pose", id = 118853736905967 },
    { name = "[BEST] Soda Pop", id = 87905326034362 },
    { name = " Zombie Run Lag", id = 100868777466223 },
    { name = "Rambunctious", id = 108128682361404 },
    { name = "Catwalk Walk", id = 87739743400914 },
    { name = "Car Pose: Tokyo Lean", id = 118859160373597 },
    { name = "Aura RNG Fly Idle ✨", id = 78755795767408 },
    { name = "Rakai Emote", id = 135686271244127 },
    { name = "Helicopter", id = 110553756436163 },
    { name = "💀MM2 Fake Dead - 2", id = 95407766746448 },
    { name = "Take The L", id = 73593666217037 },
    { name = "Nope Finger (emote)", id = 77206866044608 },
    { name = "Jabba Switchway", id = 103538719480738 },
    { name = "Tantrum", id = 5104374556 },
    { name = "Zero Two Dance V2", id = 95385842020103 },
    { name = "Confess to Me", id = 105722319548703 },
    { name = "Cute crouch ", id = 120224229260879 },
    { name = "Jumpstyle dance", id = 133248139921782 },
    { name = "It Ain't My Fault - Zara Larsson", id = 6797948622 },
    { name = "Around the Head", id = 114502615688717 },
    { name = "Gangnam Style", id = 130998336536045 },
    { name = "Fairy sit floating anime girl pose", id = 132152702263080 },
    { name = "Sit", id = 139621472081340 },
    { name = "Cha Cha", id = 6865013133 },
    { name = "Jumpstyle Dance", id = 89614983665331 },
    { name = "Hug💕", id = 88712283515515 },
    { name = "Coffin Walkout", id = 117302755748327 },
    { name = "Party Rocker", id = 96443347889042 },
    { name = "Metro Man Arm Swings Dance", id = 75757974843376 },
    { name = "Asian Squat", id = 87939646671209 },
    { name = "Helicopter", id = 140547238892659 },
    { name = "Be Tall Skinwalker Dog", id = 81694095869045 },
    { name = "Billy Bounce", id = 126516908191316 },
    { name = "Gangnam style", id = 80923445784018 },
    { name = "Xaviersobased Emote", id = 131763631172236 },
    { name = "Glitch through walls (phase)", id = 132366431744296 },
    { name = "Michael Myers Dance", id = 120250678461066 },
    { name = "how did he hit every beat", id = 134311528115559 },
    { name = "Nuh Uh! (Finger Wiggle)", id = 91380965860245 },
    { name = "Demon Slayer | Douma Sit", id = 96606489351695 },
    { name = "Brazilian Funk Footwork", id = 88693910954718 },
    { name = "Get The Money", id = 73264759706085 },
    { name = "Speed Mirage", id = 108946079729323 },
    { name = "Biblically Accurate Emote", id = 133596366979822 },
    { name = "Floating Aura", id = 79795305221612 },
    { name = "Vecna Stranger Things Fly Animation Emote Bone", id = 90555063826230 },
    { name = "Street Glide", id = 137284968787523 },
    { name = "Just be competent", id = 124041369408613 },
    { name = "Casual Sitting", id = 113039466758343 },
    { name = "On The Outside - Twenty One Pilots", id = 7422841700 },
    { name = "TYLA - CHANEL (TIKTOK DANCE)", id = 131260558736428 },
    { name = "R15 Death (Accurate)", id = 114899970878842 },
    { name = "Little jumping spider", id = 113184956127341 },
    { name = "🎃 Creepy Scene Halloween Zombie Holding Head 🎃", id = 139460224769900 },
    { name = "Flopping Fish", id = 133142324349281 },
    { name = "Gap x Katseye - Better Than yours (Milkshake ) 🔥.", id = 136084484696445 },
    { name = "Cat Nap", id = 105016815489641 },
    { name = "🔥I came to GROOVE🔥[A peanut butter house] 4'10", id = 85913265750993 },
    { name = "[R6] Otsukare Summer", id = 82461557511288 },
    { name = "Russian Dance", id = 74608751145756 },
    { name = "(Original) Gangnam Style", id = 116468071022853 },
    { name = "♡ kawaii magical girl kpop idle pose", id = 126228947948058 },
    { name = "⚡ Raiden Punching Armstrong Loop", id = 115203580644128 },
    { name = "[OG] Military Dance", id = 79318911527752 },
    { name = "Take The L", id = 133005847117851 },
    { name = "/headless /koblox .... kind of", id = 110170230382247 },
    { name = "Top Rock", id = 3570535774 },
    { name = "Tell Me, Tell Me! - Wonder Girls", id = 112118419325053 },
    { name = "Tyla Dance", id = 89145613574909 },
    { name = "Fishing", id = 3994129128 },
    { name = "Relax Flying Anime (Floating Emote)", id = 131950236025472 },
    { name = "baby boo dance", id = 78428722915978 },
    { name = "Leaning Against Wall Arms Crossed", id = 77806145358673 },
    { name = "Vibing / Community Animation Idle", id = 123355872827206 },
    { name = "Louisiana Jigg", id = 75625820126017 },
    { name = "Scene Profile Idle Pose Y2K ", id = 125386993330077 },
    { name = "Rock n Roll", id = 15506496093 },
    { name = "67", id = 120007956256550 },
    { name = "[BEST] Invisiblity", id = 130371895389423 },
    { name = "SpiderMan [Original]", id = 130987133773478 },
    { name = "[ORIGINAL] Electro Shuffle ", id = 140499299581464 },
    { name = "♡ Cute n shy Idle Emote Profile Pose", id = 135994700702758 },
    { name = "DARE - Gorillaz", id = 88840501982686 },
    { name = "Floating Princess", id = 120160563346972 },
    { name = "Dance If You're The Best - Dia Delicia Dance 😁 ", id = 70955237174596 },
    { name = "levitate", id = 87826892596287 },
    { name = "L Lawliet", id = 139435106875573 },
    { name = "Ya Ya Ying Dance", id = 130850357238599 },
    { name = "Cute Sit", id = 72947568152049 },
    { name = "/e dance2", id = 124072098165199 },
    { name = "Will has power!!! STRANGER THINGS 5 ", id = 93772541546815 },
    { name = "Imagine Dragons - “Bones” Dance", id = 15689314578 },
    { name = "Make You Mine", id = 104485625389237 },
    { name = "[⌛] Stranger Things Vecna Kill Emote", id = 80981189893654 },
    { name = "Cute Kawaii Legs Up Shy Kicking Feet Cat Laying", id = 103155280474275 },
    { name = "Golden dance [best]", id = 77945789109199 },
    { name = "Keeping Time", id = 4646306072 },
    { name = "Cute Excited Sit🦋", id = 73743026563647 },
    { name = "cute dancy dance", id = 83917238288783 },
    { name = "The Tylil Dance [Kai Cenat Dance]", id = 107010273569673 },
    { name = "pain and suffering", id = 93195109588878 },
    { name = "♡ cute halloween magical witch aura idle pose", id = 80094678034288 },
    { name = "♡ : super shy girly idle pose", id = 132436768198498 },
    { name = "MM2 Dead", id = 139859849852362 },
    { name = "Arona Dance Meme", id = 113818946774721 },
    { name = "Mesmerizer", id = 92707348383277 },
    { name = "RiRiRi Happy Halloween ", id = 98464793617142 },
    { name = "Stray Kids Walkin On Water", id = 100773414188482 },
    { name = "♡ cute bouncy anime dance", id = 108845097487486 },
    { name = "Get Out", id = 3934984583 },
    { name = "Kick It Dance Move - NCT 127", id = 12259888240 },
    { name = "(OG) Ishowspeed Shake Dance", id = 138386881919239 },
    { name = "6-7", id = 106367055475970 },
    { name = "DearALICE - Ariana", id = 133765015173412 },
    { name = "Cute Bouncy Needy Shake Dance", id = 70434485915160 },
    { name = "Rakai Dance", id = 132617851151069 },
    { name = "Sweet Hug Pose V1 [MATCHING] ", id = 100597438247721 },
    { name = "[BEST] Rakai Emote", id = 88486801093777 },
    { name = "Rock Out - Bebe Rexha", id = 18225077553 },
    { name = "Ya Ya Ying Dance", id = 115777223962514 },
    { name = "Run R15 (Fake lag)", id = 100297498958164 },
    { name = "Pangya Dance🎀", id = 89439360145889 },
    { name = "Crossed Arm Hip Sway", id = 122545939134570 },
    { name = "💗 Pangya Dance 3.0 !!", id = 136504778836355 },
    { name = "AFK Aura Farm", id = 124573843932871 },
    { name = "I Like  It - Stray kids", id = 84540347604763 },
    { name = "rolling crybaby", id = 130726889233022 },
    { name = "Halloween Headless Effortless Aura", id = 94684994062212 },
    { name = "Olivia Rodrigo Head Bop [CHEAP]", id = 79580284786292 },
    { name = "Proxima Creatura", id = 76503754262527 },
    { name = "Aura Gainer", id = 125717501705233 },
    { name = "KATSEYE TOUCH (CHEAP)", id = 75916539353418 },
    { name = "Chill Flying Levitation", id = 117049327096718 },
    { name = "SHAKE THAT SILLY THANG", id = 101532601304772 },
    { name = "needy me", id = 137894800082618 },
    { name = "ericdoa - dance", id = 15698510244 },
    { name = "Courtly bow", id = 72613272882226 },
    { name = "Lets Get Sturdy", id = 119341017234649 },
    { name = "[Aura Farm] Wall Lean Idle {ORIGINAL}", id = 110537281410647 },
    { name = "67", id = 136415352218982 },
    { name = "♡ cute shy withdrawn sit", id = 81204065393762 },
    { name = "Nya San", id = 118688124889191 },
    { name = "Peter Griffin's Death Pose", id = 99005087791705 },
    { name = "Da Hood Stomp", id = 92237689732858 },
    { name = "Emote Loading. Please Wait... | spinning Robloxian", id = 84511772437190 },
    { name = "Big Hand Wave", id = 105209959441169 },
    { name = "Boxing", id = 117648669357990 },
    { name = "Cute Sit", id = 116578970554242 },
    { name = "Sonic Adventure Profile Pose", id = 104721659176603 },
    { name = "Trendy Nicki Leg Pose", id = 92846015938931 },
    { name = "Stray Kids - Do It", id = 95256633886548 },
    { name = "Relaxed Sit", id = 99568437064777 },
    { name = "Tank", id = 85076031433488 },
    { name = " Sweet Fluffy Bunny Dance ORIGINAL", id = 85587917792339 },
    { name = "Flying Superhero Emote", id = 71574925787532 },
    { name = "♡ cutesie shy idle !!", id = 120389512169914 },
    { name = "sitting squat idle pose ", id = 113960239878969 },
    { name = "Exotic : APEX Emote [Sol's RNG]", id = 106674068664046 },
    { name = "Hug 🤗❤️", id = 102822553233176 },
    { name = "Default Dance | OG", id = 80877772569772 },
    { name = "Fancy Feet", id = 3934988903 },
    { name = "Dropkick", id = 127764273000599 },
    { name = "Speed Glitch+", id = 137006085779408 },
    { name = "disco spin 🎀 ", id = 93818150150183 },
    { name = "🕷️ Spiderman Hanging", id = 82370885440550 },
    { name = "The coolest standing pose in the world", id = 110330632237517 },
    { name = "Around Town", id = 3576747102 },
    { name = "Fling emote", id = 79026423023159 },
    { name = "kawaii whimsy airplane profile pose ʚ♡ɞ", id = 122803615354190 },
    { name = "Tail Wag Happy Idle", id = 71980669913244 },
    { name = "Katseye - Gnarly Pop Dance Emote", id = 100829635809504 },
    { name = "Dougie", id = 93675237485386 },
    { name = "Jojo Torture Dance", id = 82910305160190 },
    { name = "Jamal's Passinho (TikTok dance)", id = 75125571025711 },
    { name = "♡ : cute kawaii hugging and kicking feet", id = 117617643410205 },
    { name = "Mini Kong", id = 17000058939 },
    { name = "[ OG ] BADDIE BOUNCE", id = 116938844814178 },
    { name = "Making Faces", id = 89535391366809 },
    { name = "LE SSERAFIM - Spaghetti", id = 81216108771843 },
    { name = "La Detone - Dance", id = 103768845612667 },
    { name = "KATSEYE - Debut", id = 134531479515970 },
    { name = "Shuffling", id = 115925652377890 },
    { name = "Tuff", id = 97505694413413 },
    { name = "Beat Da Koto Nai", id = 130655908439646 },
    { name = "Slow-Mo Backflip | IShowSpeed Flip [NEW]", id = 86617727183442 },
    { name = "Cartwheel - George Ezra", id = 10370929905 },
    { name = "Sleeping Angel", id = 100885431049593 },
    { name = "FORSAKEN John Doe Pose ", id = 104072580597361 },
    { name = "Ay-Yo Dance Move - NCT 127", id = 12804173616 },
    { name = "💩MEGA POOPING 💩 [AURA] 😂", id = 106880906271071 },
    { name = "[RAPID FIRE] 🔫 Gun Morph", id = 73562814360939 },
    { name = "Rat Dance Meme", id = 79460913196046 },
    { name = "Sleeping Sideways", id = 113546798537900 },
    { name = "PangYa Dance 3.0", id = 95926267112611 },
    { name = "Michael Myers", id = 103115491327846 },
    { name = "Fake R15 Zombie Run Lag", id = 106878897156217 },
    { name = "Panic Run", id = 79338722896418 },
    { name = "Hey Ya Move", id = 104338766814874 },
    { name = "Aura Idle", id = 82096188761745 },
    { name = "Wally Speedster Run", id = 133948663586698 },
    { name = "Idol", id = 4102317848 },
    { name = "Cry For Me [OG]", id = 98263064912190 },
    { name = "Blue Top Rock", id = 103438127343286 },
    { name = "Rafa Polinesio Baile", id = 133047022806044 },
    { name = "California Girl Dance [OG]", id = 132074413582912 },
    { name = "Flying Pose Emote", id = 97130179011866 },
    { name = "✅ Obby - Emote", id = 76394392186917 },
    { name = "Aura Farming", id = 133113167814737 },
    { name = "Phut On", id = 139830733782518 },
    { name = "🕷️ Realy strange Hornet's Spider", id = 114530046828576 },
    { name = "Signature Shuffle", id = 81442470330880 },
    { name = "Get Sturdy", id = 120896030393583 },
    { name = "Mannrobics (TF2)", id = 83702306317443 },
    { name = "[MIRA] Kicking Feet Sit", id = 78758922757947 },
    { name = "New Jeans - Hype Boy Dance", id = 77813688815637 },
    { name = "67", id = 112661109226148 },
    { name = "Be tall creature", id = 87939300658851 },
    { name = "🤍 cute n timid idle profile pose", id = 110252467018810 },
    { name = "I'm Talm 'Bout Innit (OG)", id = 117301403779781 },
    { name = "Soda Pop - Saja Boys", id = 88398357963696 },
    { name = "[ORIGINAL] I Want Money / What You Want - EMOVA", id = 128258195574116 },
    { name = "YUNGBLUD – HIGH KICK", id = 14022978026 },
    { name = "[Best] All Might Victory Pose R6", id = 100416618991324 },
    { name = "7 Rings Dance ", id = 127478024269658 },
    { name = "⸸꒱ Ya Ya Ying Dance [OG]", id = 121076776003313 },
    { name = "Just Your Doll ", id = 78724951673945 },
    { name = "⏳[BEST] Meow Meow Dance", id = 70929692881143 },
    { name = "Air Dance", id = 4646302011 },
    { name = "Rabbit Hole - Miku", id = 133481721436918 },
    { name = "Y", id = 4391211308 },
    { name = "Take The L", id = 112884830175040 },
    { name = "MOSH", id = 118307905798773 },
    { name = "intrusive awkward wave", id = 85665834724929 },
    { name = "IShowSpeed Bounce Dance", id = 140269876098643 },
    { name = "Godly Aura floating Emote", id = 102392888934746 },
    { name = "Rose Gift ", id = 132380943956928 },
    { name = "Gangsta Walk", id = 120025592354724 },
    { name = "Car Transforming", id = 79360981055415 },
    { name = "ALTÉGO - Couldn’t Care Less", id = 92859581691366 },
    { name = "Silly Animals Dance", id = 70888470847518 },
    { name = " Sad Depressed Crying Sit / Sitting", id = 95339652051393 },
    { name = "2 Phut Hon Dance", id = 115319301809339 },
    { name = "♡ : kawaii plushie hug idle pose", id = 110116680249979 },
    { name = "Belly Dancing", id = 131939729732240 },
    { name = "BLACKPINK - Get em Get em Get em", id = 131561465960751 },
    { name = "Floating Throne Aura Pose", id = 93443111556634 },
    { name = "Swaying Sit", id = 120565455646158 },
    { name = "R6 Califorina Girls [Forsaken]", id = 84430246447182 },
    { name = "Hakari Dance", id = 131013239122616 },
    { name = "🪙 Relax Coin Flip", id = 128000234046934 },
    { name = "Alo Yoga Pose - Warrior II", id = 12507106431 },
    { name = "SUIIIIII", id = 72049728640815 },
    { name = "67", id = 79159574589173 },
    { name = "hands down hip sway", id = 104660720214070 },
    { name = "head spin", id = 140466682449054 },
    { name = "Scary tall creature transformation ", id = 93875137466223 },
    { name = "Red Carpet Walk💅(Fortnite)", id = 108683274449989 },
    { name = "[🔫]Finger-Gun", id = 138671863009472 },
    { name = "Gojo Floating JJK/ The Honored One", id = 91085159191582 },
    { name = "Ishowspeed Shake Dance", id = 74646784680842 },
    { name = "Spin Around with a Friend Matching [Original]", id = 74809337211634 },
    { name = "AOK - Tai Verdes", id = 7942960760 },
    { name = "TMNT Dance", id = 18665886405 },
    { name = "Money Hop Spin", id = 126821507055878 },
    { name = "Jawny - Stomp", id = 16392120020 },
    { name = "California Girls", id = 130248288787333 },
    { name = "[🎃Halloween] Headless Floating Aura", id = 73723042388431 },
    { name = "Hotel Transylvania macarena dance", id = 81808860196321 },
    { name = "Cute Hug Pose 1 [MATCHING]", id = 81874921102056 },
    { name = "Urban Dance", id = 89466407313325 },
    { name = "cute doll ballerina music box spin", id = 111332667359868 },
    { name = "Spongebob Shuffle Dance 🧽", id = 107899954696611 },
    { name = "💅 Baddie Belly Dance", id = 108076240512174 },
    { name = "Little Obbyist", id = 134584040095037 },
    { name = "Saturday Dance - Twenty One Pilots", id = 7422833723 },
    { name = "Super Charge", id = 10478368365 },
    { name = "Slow Dembow", id = 73236219340808 },
    { name = "KATSEYE - Gabriela", id = 115661091136535 },
    { name = "Die Lit", id = 121001502815813 },
    { name = "Bubbly Sit [3.0]", id = 82070133181200 },
    { name = "beautiful dance", id = 104077918384157 },
    { name = "Cute Bouncy Hip Shake Dance", id = 87963462118126 },
    { name = "cute sit", id = 131875333242836 },
    { name = "Money Hop Switch", id = 134222090358172 },
    { name = "Wally's Pose", id = 131961970776128 },
    { name = "Mae Stephens – Arm Wave", id = 16584496781 },
    { name = "cute floating headless head aura emote", id = 98728517497209 },
    { name = "Sleeping Soundly", id = 104024961010344 },
    { name = "💀Emergency Hamburg Fake Dead", id = 117316258600620 },
    { name = "AY MI GATITO DANCE [cheap]", id = 88373786916619 },
    { name = "cute bossy girl pose ♡୨୧", id = 135078245258688 },
    { name = "Michael Myers Bounce [NEW VERSION]", id = 139749659598065 },
    { name = "head levitating cool pose", id = 111474274315212 },
    { name = "♛ Honor Knight Kneel", id = 103663987050338 },
    { name = "Helicopter Spin", id = 84555218084038 },
    { name = "Billy Bounce", id = 93450937830334 },
    { name = "Biblically Accurate Angel", id = 70544785852547 },
    { name = "I Want Money (Prince of egypt)", id = 133751526608969 },
    { name = "2 Baddies Dance Move - NCT 127", id = 12259890638 },
    { name = "Scene Pose", id = 139344101676103 },
    { name = "Tank Transformation", id = 132382355371060 },
    { name = "CUTE SIT", id = 113112871341684 },
    { name = "Michael Myers Shake Dance", id = 116669353996297 },
    { name = "♥️Otsukare summer", id = 111032510525800 },
    { name = "Cobra Arms - Tai Verdes", id = 7942964447 },
    { name = "[R6] Nyan Cat Meme", id = 79483479695611 },
    { name = "Chinese Dance: Da Koto Nai [BEST]", id = 104539498095025 },
    { name = "Fashionable [CHEAP]", id = 93285483814710 },
    { name = "Big Papa Squat", id = 114443541753616 },
    { name = "New Jeans - Hype Boy", id = 112819653616515 },
    { name = "Aura Sit", id = 136914725915863 },
    { name = "Jacks", id = 3570649048 },
    { name = "Alo Yoga Pose - Triangle", id = 12507120275 },
    { name = "Wanna play?", id = 16646438742 },
    { name = "Internet Girl - Katseye (Eat Zucchini) 🔥", id = 120642998230445 },
    { name = "Heart", id = 84396003438766 },
    { name = "Golden freddy idle", id = 140677562143416 },
    { name = "Big G Bounce", id = 70975021709810 },
    { name = "Discombobulated", id = 129916107176034 },
    { name = "Rat dance", id = 121838903053629 },
    { name = "Cute kicking Feet Sit", id = 130253041293561 },
    { name = "Diva Aura", id = 118846519181951 },
    { name = "Push Up 💪", id = 98401523334482 },
    { name = "Alibi - TikTok Dance", id = 140278625941166 },
    { name = "Rat Dance", id = 105515769832740 },
    { name = "Spice Floor Call", id = 103399717097173 },
    { name = "TYLA - CHANEL", id = 103284570577508 },
    { name = "Garry's Dance", id = 92853367837757 },
    { name = "Head Pat High [Matching Set]", id = 120833029935011 },
    { name = "⭐(BEST) KATSEYE - TOUCH (CHEAP)⭐", id = 89292402527476 },
    { name = "Wall Lean Pose", id = 81641039996152 },
    { name = "Thank You Bow Ladies and Gentlemen ", id = 132566708912466 },
    { name = "Big Back Baby Boo", id = 122461225964217 },
    { name = "Spongebob", id = 123043305808890 },
    { name = "Levitation Idle Emote 2", id = 111499780397123 },
    { name = "Hero Fly Loop - Superhero Flying", id = 117931620432186 },
    { name = "Dougie Meme Dance", id = 119256963154827 },
    { name = "Choso", id = 119042829278898 },
    { name = "Sukuna Aura Pose", id = 138453007205351 },
    { name = "Torture Dance", id = 81780730637211 },
    { name = "Iconic Fashion Model Idle Pose", id = 80004965633316 },
    { name = "Rolling Stones Guitar Strum", id = 18148839527 },
    { name = "Catwalk Walk Emote (FIRST,OG)", id = 138140141577966 },
    { name = "Boogie Down", id = 139570238573569 },
    { name = "Catwalk Walk", id = 120380776076922 },
    { name = "Garry's Dance (GMOD)", id = 129861012882037 },
    { name = "Buss It! [OG]", id = 131407261984740 },
    { name = "Druski Pop Out", id = 98405298116702 },
    { name = "Golden Freddy Pose", id = 71363859760586 },
    { name = "67 ", id = 117781289000852 },
    { name = "Nyan Cat", id = 129661231092261 },
    { name = "HEADLESS HOOPER - basketball", id = 80436375269036 },
    { name = "Confess Dance", id = 81671884508244 },
    { name = "Rock Out", id = 136905358266269 },
    { name = "Floating sitting ", id = 83186041767510 },
    { name = "Sit", id = 90221568176994 },
    { name = "Vibing / Community Animation Aura Idle", id = 70508706371253 },
    { name = "Pasinho do Jamal", id = 71286446361487 },
    { name = "Flat Sitting Pose", id = 81180825463784 },
    { name = "Spice N’ Slide", id = 103814076459025 },
    { name = "Brazillian Vibe", id = 112528616743393 },
    { name = "♡ Cute Wave Pose ♡", id = 102370555981017 },
    { name = "Hakari Jujutsu Kaisen Dance", id = 103612146839392 },
    { name = "Wall Lean", id = 88969192102242 },
    { name = "Sukuna Aura Idle", id = 89424059240713 },
    { name = "Fake MM2 Death", id = 107498554725527 },
    { name = "Do That Thang", id = 98064631733787 },
    { name = "Pennywise Dance", id = 132496870420627 },
    { name = " 67 ! Six Seven ", id = 92118471015650 },
    { name = "Trim Boat  Dance!", id = 115215660256998 },
    { name = "The Run Around", id = 88834614877886 },
    { name = "FNaF Jumpscare", id = 114306032029835 },
    { name = "TWICE I GOT YOU part 1", id = 16215060261 },
    { name = "xaviersobased", id = 87756443172440 },
    { name = "Spicy Life Dance", id = 106381695975693 },
    { name = "Forsaken Mafiaso Pose", id = 121613692928115 },
    { name = "Hear Us Now!", id = 91110020647774 },
    { name = "No Clip/Speed Glitch", id = 87141651594092 },
    { name = "rat dance [R6]", id = 128109831935307 },
    { name = "Low Cortisol", id = 74477507917814 },
    { name = "Jubi Slide (Fortnite)", id = 119701068949532 },
    { name = "baddie", id = 125699260461610 },
    { name = "Dance All Night", id = 97139559228653 },
    { name = "♡ soft elegant stance !!", id = 90478555055303 },
    { name = "Cute Sit ", id = 90244178386698 },
    { name = "Jotaro Pose (aura)", id = 104330991197585 },
    { name = "BLACK PINK JUMP - LOOP ", id = 97881883432866 },
    { name = "Baddie Shake", id = 134817530495903 },
    { name = "Backflip", id = 91583499354581 },
    { name = "/e Fly - Accurate Admin Fly 🐤", id = 97830214926142 },
    { name = "67", id = 96228944634706 },
    { name = "Aura Float", id = 114469314321726 },
    { name = "Bouncy Cute Girl Anime Idle", id = 74193679388896 },
    { name = "Springtrap Dance", id = 132007669525235 },
    { name = "M3GAN's Dance", id = 127271798262177 },
    { name = "Chinese Soldier Pose ", id = 95918522631092 },
    { name = "Street Flow Bounce", id = 91773089278851 },
    { name = "Festa No Brasil - Fortnite", id = 92594494443322 },
    { name = "Fake Lag/Disconnect (TROLL)", id = 97523498583729 },
    { name = "Sonic You're Too Slow (Animated Face)", id = 103737097131582 },
    { name = "67 Emote (Dynamic)", id = 92707729249136 },
    { name = "Sit Comfy Idle", id = 91223337249721 },
    { name = "Helicopter", id = 119431985170060 },
    { name = "Shattered", id = 124305244640379 },
    { name = "💩 MEGA POOP SNIFF 😂 [AURA]", id = 82904146092287 },
    { name = "Floating Upside-Down!", id = 95999178112240 },
    { name = "Sturdy R6", id = 92335786854446 },
    { name = "Show work", id = 138056642423260 },
    { name = "Gojo Pose (Floating)", id = 125866557084286 },
    { name = "Play Dead Troll Trick Emote mm2 pose fake ragdoll", id = 89115363544461 },
    { name = "Reze Dance (Iris Out)", id = 91032553512904 },
    { name = "inchworm", id = 95339769038863 },
    { name = "꒰ cute plush hug ♡ ꒱", id = 81093485407431 },
    { name = "Levitated Lounge", id = 100081021028089 },
    { name = "[R15] Hatsune Miku Idle Pose Emote", id = 74402735640939 },
    { name = "SpongeBob Imaginaaation 🌈", id = 18443268949 },
    { name = "Floating Sit", id = 83475540437708 },
    { name = "Sit", id = 132738611207490 },
    { name = "♡ Magical Float ", id = 87526114329356 },
    { name = "Meow Meow", id = 71666111389227 },
    { name = "Drum Master - Royal Blood", id = 6531538868 },
    { name = "GRIMES - Oblivion", id = 78660312825816 },
    { name = "Sit", id = 93262662842394 },
    { name = "kawaii chibi pose ", id = 91333024824710 },
    { name = "Headless", id = 74738520664045 },
    { name = "🕷️ Spider-Man Hanging 2", id = 139402543978841 },
    { name = "Michael Myers Bounce come on don't hide Emote", id = 79299166779744 },
    { name = "Hakari Dance", id = 115380777754385 },
    { name = "Kawaii Groove", id = 94792423330715 },
    { name = "L Dance", id = 114846964045392 },
    { name = "Naruto Run", id = 120668080412453 },
    { name = "Swish", id = 3821527813 },
    { name = "Luffy Gear 5 Laugh [High Quality]", id = 106008592717540 },
    { name = "Smooth Rizz Rose", id = 83362314681140 },
    { name = "Olivia Rodrigo good 4 u", id = 15554013003 },
    { name = "Fling emote V2", id = 123929740439299 },
    { name = "Rock Guitar - Royal Blood", id = 6532155086 },
    { name = "Gangster Delinquent Crouch", id = 137201675761037 },
    { name = "Upside down floating AURA", id = 89468381929192 },
    { name = "Vecna Kill", id = 138214580770869 },
    { name = "Birdbrain", id = 120486252224195 },
    { name = "High Hands", id = 9710994651 },
    { name = "Head Banger [Travis Scott]", id = 81621254772462 },
    { name = "Little Soda Pop", id = 92469700143086 },
    { name = "SIUU", id = 137282858118997 },
    { name = "99 Nights Kid Crying", id = 75968890183942 },
    { name = "Spicy Flow Vibes", id = 124212021234700 },
    { name = "Head scratches / Head pats", id = 123663633846435 },
    { name = "Stylish Sit", id = 112035743224829 },
    { name = "Teto Territory", id = 97263450325496 },
    { name = "Macarena", id = 73946479113094 },
    { name = "Kawaii Headless Holding Head Idle Emote", id = 101446789686277 },
    { name = "Hear Me Now", id = 113116746603315 },
    { name = "Relaxed Sit", id = 111231236978253 },
    { name = "R6 Peanut Butter Jelly (Die Of Death)", id = 100267888506831 },
    { name = "Electro Shuffle", id = 96426537876059 },
    { name = "Idol - Saja Boys", id = 93669846092172 },
    { name = "Michael Myers dance", id = 83430340523948 },
    { name = "Vampire Pose [ORIGINAL]", id = 113919169704818 },
    { name = "♡ Cute Kawaii Shy Doll Stance", id = 78712622250645 },
    { name = "Jumpstyle Dance", id = 75044579039280 },
    { name = "Big G Rilla Step", id = 78512766320761 },
    { name = "Rat Dance", id = 94083401455021 },
    { name = "Jumpstyle", id = 99563839802389 },
    { name = "Vogue Dip", id = 110881393097630 },
    { name = "A Rose?🌹", id = 91739079549341 },
    { name = "Ima sit back | Baddie Emote", id = 74726067041025 },
    { name = "Pangya Dance (HQ)", id = 135495405058646 },
    { name = "The Mimic [SPOOKY SCARY HALLOWEEN]", id = 71350324794436 },
    { name = "Laying on clouds", id = 80422524668416 },
    { name = "rollie ", id = 124522011862575 },
    { name = "Yanagi walking", id = 134222958219878 },
    { name = "Sukuna Levitating", id = 127504816844209 },
    { name = "Sukuna Aura Farming", id = 73532860571147 },
    { name = "kawaii cute cat girl pose idle", id = 138487798883208 },
    { name = "Hakari Dance V2", id = 77666131363559 },
    { name = "Miau Miau 💖", id = 97057654852515 },
    { name = "♡ cute bossy sassy girl idle pose", id = 137909901344953 },
    { name = "BADDIE Mirror Pose 💅 ", id = 74621691174733 },
    { name = "/e fling [BEST]", id = 77917153071278 },
    { name = "candy cookie chocolate miku teto", id = 121463501824419 },
    { name = "Needy Cartwheel Split", id = 91490872407594 },
    { name = "cat loaf", id = 70978791982917 },
    { name = "[BEST] Rat Dance Meme", id = 129012429034007 },
    { name = "🤪Skibidi Shake⚡", id = 80115988215727 },
    { name = "[10K⭐] Full Masked Mark Pose Day 3 (Invincible)", id = 100184686550276 },
    { name = "Make You Mine", id = 130214067086591 },
    { name = "Wisp - air guitar", id = 17370797454 },
    { name = "(FNAF) Burger King/BK-Worker-Cringe-Poses", id = 126292183096601 },
    { name = "Onion", id = 123015710605336 },
    { name = "Big Hand Come Here", id = 91077746625220 },
    { name = "Sticker Dance Move - NCT 127", id = 12259885838 },
    { name = "Invisible (Glitch Under)", id = 83522304666655 },
    { name = "Forsaken Injured Idle Animation Troll", id = 135857194183404 },
    { name = "Snow angels", id = 135922662345048 },
    { name = "KATSEYE - Gabriela (Megan)", id = 98012296914799 },
    { name = "Back Dance Trend", id = 80242782087423 },
    { name = "Elevation", id = 134928834792631 },
    { name = "cute gasp 😱", id = 132029163919678 },
    { name = "tanging philly", id = 84028672169998 },
    { name = "Swinging", id = 103664927117916 },
    { name = "Dancing with your eyes closed", id = 129637389787927 },
    { name = "PARROT PARTY DANCE", id = 121067808279598 },
    { name = "Spice Happy Jumping", id = 133319600812587 },
    { name = "Fling Emote (WORKS 2025)", id = 127696159883730 },
    { name = "Getting Sturdy", id = 121577088569956 },
    { name = "Gameboy - Katseye", id = 117453574553102 },
    { name = "Onion", id = 113890289455724 },
    { name = "JUMP - BP (KPOP)", id = 122404842843791 },
    { name = "[🎀CUTE] Kayah's Cute Pose", id = 124031351335869 },
    { name = "Belly Dance", id = 128920596154369 },
    { name = "Baddie Hips", id = 74731877336606 },
    { name = "Swan Dance", id = 7466048475 },
    { name = "Meow Meow (Miau Miau)", id = 90390772674600 },
    { name = "Nagi Seishiro's Celebration", id = 94925651501842 },
    { name = "Like Jennie Dance from JENNIE", id = 92224509275999 },
    { name = "Childish Tantrum", id = 130575801528647 },
    { name = "Cool Backflip", id = 117168959477820 },
    { name = "True Heart", id = 103168660352906 },
    { name = "Drum Solo - Royal Blood", id = 6532844183 },
    { name = "Soda Pop", id = 105669765010094 },
    { name = "Absolute Sadness", id = 92893440808720 },
    { name = "Sweet Sit Pose (Ledge sitting)", id = 103541659586127 },
    { name = "Laying Down - Daydreaming", id = 89174456614428 },
    { name = "Stateside - 🔥 PinkPantheress + Zara Larsson", id = 85028685451071 },
    { name = "Shake That", id = 129424335541851 },
    { name = "Arthur Morgan Coughing", id = 84293478473291 },
    { name = "Sonic the Hedgehog Super Smash Bro Profile Pose", id = 129850521517715 },
    { name = "Kick", id = 108296873775004 },
    { name = "Big Guy Spongebob Dance - Ice Spice", id = 123529590259591 },
    { name = "[BEST] Keep The Money Flipping", id = 106656731585855 },
    { name = "The Zabb", id = 71389516735424 },
    { name = "Rock Star - Royal Blood", id = 6533100850 },
    { name = "Party Rock Anthem", id = 105248382902194 },
    { name = "Block Partier", id = 6865011755 },
    { name = "Eleven Stranger Things 5", id = 129735512772535 },
    { name = "Louisiana Jigg 2", id = 125646873823019 },
    { name = " Jinu Pose - Saja Boys", id = 130641944883645 },
    { name = "Scenario [OG] - LOVE SCENARIO", id = 103046131635200 },
    { name = "Dave's Spin Move - Glass Animals", id = 16276501655 },
    { name = "Low Cortisol Dance Pill", id = 125822752810863 },
    { name = "Cute Needy Shake Dance ", id = 101044624010591 },
    { name = "Creepy Ventriloquist Puppet", id = 95800106960533 },
    { name = "Moon walk", id = 79905360809057 },
    { name = "Obby", id = 88848066429450 },
    { name = "Animal Run", id = 135323028794768 },
    { name = "[🎀CUTE] Catwalk Walk Girly", id = 131907146446807 },
    { name = "Gojo Floating The Honored One", id = 100953557187752 },
    { name = "kicking your feet", id = 70788193750089 },
    { name = "Go Mufasa", id = 94118707925458 },
    { name = "Nyan Cat 🌈", id = 109073518888589 },
    { name = "MM2 Dead Troll", id = 95877955786500 },
    { name = "TWICE I GOT YOU part 2", id = 16256253954 },
    { name = "MM2 Fake Dead Pose!", id = 83548980186247 },
    { name = "/e orbit", id = 91729309021707 },
    { name = "airbending dance", id = 112732073090025 },
    { name = "(BEST!) Invincible Variant Edit Flight Idle", id = 89275236036624 },
    { name = "What You Want / Prince of Egypt Dance", id = 107978036345855 },
    { name = "Matching Hug [1]", id = 83878498166514 },
    { name = "I see Kareem Groove", id = 85913309003871 },
    { name = "67", id = 95165285320591 },
    { name = "Hear Me Now", id = 98466571496349 },
    { name = "La anguila hip (MEME)", id = 103386082503086 },
    { name = "Corrupted Entity", id = 104321872987170 },
    { name = "Griddy (BEST)", id = 77017926307035 },
    { name = "Agnes Tachyon's Low Cortisol Dance (In Tempo) V1", id = 112396548575695 },
    { name = "JoJos | Jonathan's Pose", id = 84195923658292 },
    { name = "Aura Farm Kid", id = 108330506883747 },
    { name = "Shy hip sway ", id = 100107749035207 },
    { name = "Goku's Warmup", id = 108013663975520 },
    { name = "Jelly Dance! (Insp. by Jellyous - ILLIT)", id = 131421601916582 },
    { name = "Dance If You're The Best - Dia Delicia Dance ", id = 117033010486869 },
    { name = "Sneaky", id = 3576754235 },
    { name = "Caramell", id = 85936805522788 },
    { name = "Hear Me Now", id = 78286660563122 },
    { name = "For Eman", id = 86748908374413 },
    { name = "Cute kawaii girly magical idle Profile pose", id = 128174269567586 },
    { name = "Skibidi", id = 124828909173982 },
    { name = "Cute Baddie Profile Pose 3.0 ꨄ Profile/Idle", id = 136040668407140 },
    { name = "Reze Dance (HQ)", id = 87471384477488 },
    { name = "Your Idol", id = 102459750208463 },
    { name = "Goofy Orange Cat Dance", id = 100015044616958 },
    { name = "Biblically Accurate Emote ", id = 118314972618293 },
    { name = "Become A Car!", id = 131544122623505 },
    { name = "♡ Bear hug 2", id = 138841588208046 },
    { name = " [BEST] Sukuna Aura Farming", id = 122364140351186 },
    { name = "👑Popular ", id = 90880350857136 },
    { name = "[BEST] Not Cute Anymore - KPop Dance (ILLIT)", id = 107753335763254 },
    { name = "Cute Hips Profile Pose", id = 86039610121898 },
    { name = "Gnarly (Gang Gang Gang) Dance", id = 79596845539490 },
    { name = "cute ponpon dance og", id = 114462336086965 },
    { name = "Scary Entity", id = 82999087084315 },
    { name = "♡ (BEST) sassy model catwalk diva", id = 137435098987579 },
    { name = "♡ Cute Heart Hands Emote Profile Pose", id = 89791686345950 },
    { name = "[ OG ♡ ] brooklyn pop - kawaii hip swing dance", id = 104060042886647 },
    { name = "Piccolo Aura Farm", id = 109174054880976 },
    { name = "Sit", id = 126614732606871 },
    { name = "Hakari Dance [FORSAKEN]", id = 98901420955781 },
    { name = "Long Legs", id = 108775322212024 },
    { name = "BIGGEST TALLEST Ancient Robloxian (GLITCH)", id = 137432224827301 },
    { name = "Jax Toy - Digital Circus", id = 111491569569071 },
    { name = "/e sit", id = 129668542320076 },
    { name = "Be Not Afraid", id = 70635223083942 },
    { name = "Proud Heel Stretch", id = 137746067965316 },
    { name = "TWICE Takedown pt 1 from Kpop Demon Hunters", id = 94796833553521 },
    { name = "NewJeans - ETA", id = 94694691436126 },
    { name = "Zombie [CHEAP]", id = 84939666256580 },
    { name = "Jojo | Shadow Dio Pose (Arcade)", id = 140372305863284 },
    { name = "Runny Dance", id = 126226506101092 },
    { name = "🐾 Furry Running 🦊 ", id = 127131085046464 },
    { name = "Pose for the Pic 📸", id = 108922782921118 },
    { name = "Uzi Quickstep - Top Rock", id = 89982755945108 },
    { name = "Rat Dance", id = 95323795166399 },
    { name = "Honor Knight Kneel Dark Souls", id = 89198573930777 },
    { name = "Inactivity With Arms Crossed", id = 108771805233715 },
    { name = "♡︎ : cute nezuko kicks in air", id = 100382290818719 },
    { name = "Gmod - Crowbar Looking Around", id = 102223494758433 },
    { name = "♡ : cutest doll alive idle pose", id = 120609908538791 },
    { name = "adidas aura farm", id = 93031389900156 },
    { name = "Zombie Run", id = 138431313591911 },
    { name = "Metroman Guitar Aura", id = 126374284262043 },
    { name = "Scene roblox profile pose", id = 96118122806813 },
    { name = "sit", id = 120512834137418 },
    { name = "Pocoyo Dance", id = 76727264948158 },
    { name = "Honored Gojo Idle", id = 128399543093532 },
    { name = "Just Feeling It", id = 134842828741769 },
    { name = "Ronaldo Siuuu Celebration", id = 107447321843426 },
    { name = "Halloween Headless Aura Pose", id = 92584189942958 },
    { name = "Jumpstyle", id = 92031196891153 },
    { name = "Louder", id = 3576751796 },
    { name = "Side Sit", id = 85370173309996 },
    { name = "Nyan Cat", id = 94309572610544 },
    { name = "👹 Sukuna Aura Farming Pose👹", id = 134893423132417 },
    { name = "Khaby Lame Mechanism 😐", id = 104423491517780 },
    { name = "Glitch", id = 91635672521214 },
    { name = "FORSAKEN c00lkid Pose", id = 135586253433745 },
    { name = "Needy Backflip Split! (OG)", id = 81249799283292 },
    { name = "6 7 Transformation", id = 75703899901487 },
    { name = "KATSEYE - Gabriela", id = 127007333011609 },
    { name = "Flying Celestial Dunhuang Feitian Apsara Immortal", id = 134683696656199 },
    { name = "Iconic Pose", id = 107391441166760 },
    { name = "Godly Aura Pose", id = 134388005886833 },
    { name = "Logan Paul Splits", id = 135583314999205 },
    { name = "Fake Dead (MM2 Troll)", id = 80977642444765 },
    { name = "JoJo Dio Pose", id = 112924687333965 },
    { name = "♡ cute kawaii side hug ... pose !", id = 88509051532516 },
    { name = "[R6] Die of Death: Squingle Emote", id = 120729591181174 },
    { name = "Umamusume Dance", id = 130838810836830 },
    { name = "Tommy K-Pop Mic Drop", id = 14024722653 },
    { name = "Sad Crying Sit", id = 137798892265594 },
    { name = "Static Hatsune Miku", id = 89824446568758 },
    { name = "Blob Victory Dance", id = 114705484108892 },
    { name = "(Updated) Huda Handstand ", id = 86652617510177 },
    { name = "Front Flip", id = 116728799092339 },
    { name = "Strutting fashion catwalk", id = 96086661098597 },
    { name = "Druski Dance", id = 120990801438458 },
    { name = "float", id = 104491001585941 },
    { name = "Miss The Quiet [BEST]", id = 136936175263593 },
    { name = "🔥 Coco Chanel Dance", id = 77712734819728 },
    { name = "Omni-Mark Fly [Invincible]", id = 123347895201748 },
    { name = "Sonic the Hedgehog Run", id = 132168791204839 },
    { name = "Hype Boy - NewJeans", id = 87929207759022 },
    { name = "dwerk", id = 94291936264690 },
    { name = "Miku Live", id = 99038386766744 },
    { name = "Goku SSJ Rage", id = 73708713364616 },
    { name = "[ OG ] Peter Griffin Death Pose Meme", id = 134521545276284 },
    { name = "Logan Paul Splits V2", id = 95567185677058 },
    { name = "Side Hug!", id = 94509894558624 },
    { name = "Angry Idle", id = 91171596265030 },
    { name = "Miku Beam Emote", id = 135545153917736 },
    { name = "Funny Goofy Wiggle", id = 74277551575520 },
    { name = "JUMPSTYLE | FALL FROM THE SKY", id = 85528043259864 },
    { name = "(BEST) Sinister Mark Pose Day 3 (Invincible)", id = 130122587580676 },
    { name = "Heavy Sword Stance", id = 109863797124787 },
    { name = "CEREMONY - Stray kids", id = 81765709820365 },
    { name = "Work It", id = 127422170075608 },
    { name = "Boom Boom Clap - George Ezra", id = 10370934040 },
    { name = "Arms Crossed Arms Emote", id = 120083676685180 },
    { name = "GAG IT DEATH DROP", id = 134737246939931 },
    { name = "JUMP K-POP Dance Choreo", id = 111481711726876 },
    { name = "Headless kawaii Holding Head Idle Emote", id = 137248338914313 },
    { name = "Baby Queen - Face Frame", id = 82960976595139 },
    { name = "Dos Tres Trucos Iconic Dance", id = 90064231932270 },
    { name = "♡ cute kawaii girly idle pose 2", id = 90831367043789 },
    { name = "Helicopter", id = 123275002792718 },
    { name = "Elton John - Heart Skip", id = 122501033570482 },
    { name = "67", id = 112755826646569 },
    { name = "Bust It Down!", id = 88164107371806 },
    { name = "Take The L - Meme Emote", id = 133545170540942 },
    { name = "Bang Head on Wall", id = 90144236147420 },
    { name = "☠︎ Myspace Cute Scene Pose XD ☠︎", id = 73002781025226 },
    { name = "Stray Kids - Chk Chk Boom", id = 90886319632623 },
    { name = "Jackpot Dance", id = 81005824258133 },
    { name = "Victory Dance", id = 77727141076962 },
    { name = "Kaiser Celebration Blue Lock", id = 124730432856533 },
    { name = "headpet", id = 89968618726000 },
    { name = "Wall Lean - hvnsnt", id = 114011952994806 },
    { name = "Deltarune - Tenna Kick", id = 111434734435321 },
    { name = "Angry Stomp ", id = 88598010609888 },
    { name = "Floating Adonis (Matching Floating Goddess) (WXW)!", id = 126073788194793 },
    { name = "CORTIS - GO!", id = 99897707960183 },
    { name = "67 Emote Hands [BEST⭐]", id = 91930645156022 },
    { name = "۶ৎ cute pose ", id = 73781389282146 },
    { name = "💕 Hug [Player 1]", id = 102303622774230 },
    { name = "Candy Emote", id = 75773776265985 },
    { name = "♡ : i'm an adorable doll cute idle pose", id = 72722490282598 },
    { name = "IShowSpeed Dance", id = 109755476052324 },
    { name = "♡  christmas winter ice skating", id = 131222297033593 },
    { name = "Miku's Mesmerizer", id = 83716500004313 },
    { name = "[ OG ♡ ] bunny party dance", id = 104922087218459 },
    { name = "jay guapo Dance (pink cardigan)", id = 74316585275133 },
    { name = "Very Honored One Gojo Pose Emote", id = 116282660846752 },
    { name = "Ella Mai - Dance", id = 103948740090967 },
    { name = "Lily Braids", id = 75503857471233 },
    { name = "P.B.J.T.", id = 88721672617892 },
    { name = "Saja Boys Pose (K-Demon Hunters)", id = 88366450739039 },
    { name = "KSI - Wake Up Call", id = 107043196201393 },
    { name = "Lush Life", id = 138629137053256 },
    { name = "Mesmerizer", id = 119327767466430 },
    { name = "💀 MM2 Fake Dead - 1", id = 103683627346536 },
    { name = "Cozy Hug Pose V1 [MATCHING]", id = 133508585947629 },
    { name = "Lady Gaga - Abracadabra", id = 71245818535880 },
    { name = "Harley Dance", id = 119258520125004 },
    { name = "FORSAKEN 1x1x1x1 Pose", id = 86685963381615 },
    { name = "(Die of Death/Forsaken) Pursuer-Raging Pace-Stalk", id = 96104534256585 },
    { name = "Naruto Run", id = 103687415030735 },
    { name = "Rasputin – Boney M.", id = 133477296392756 },
    { name = "🎀 Cute Head Tilt Idle Pose", id = 114854634677146 },
    { name = "Ya Ya Ying Dance [OG]", id = 114457468919031 },
    { name = "Speakerman Dance", id = 116622848811955 },
    { name = "Trip Out", id = 135599476494116 },
    { name = "Rat Dance", id = 83606297144428 },
    { name = "(Forsaken) Guest 666/Furry-Old Running-Animation", id = 128650099590921 },
    { name = "Silly Cat AI Dance", id = 103463979134756 },
    { name = "Soda Pop Saja Boys", id = 97614587826828 },
    { name = "Baddie Roblox Profile Pose", id = 113365621555609 },
    { name = "Up and Down - Twenty One Pilots", id = 7422843994 },
    { name = "criss cross sit", id = 91423783304464 },
    { name = "Jump Spin Animation", id = 99410306126683 },
    { name = "MM2 fake dead troll", id = 131830337253229 },
    { name = "Invisible", id = 101801833201272 },
    { name = "L Lawliet Sit", id = 140187771377253 },
    { name = "Gojo Dead", id = 123470584988273 },
    { name = "Cutesy Cat Sit Profile Pose", id = 72185261708093 },
    { name = "GNARLY DANCEBREAK - KATSEYE", id = 92036309063784 },
    { name = "Bendy Class Dance", id = 97856916779483 },
    { name = "/e dance1", id = 122117255044047 },
    { name = "MM2 Dead Troll Front", id = 87240345883758 },
    { name = "Mean Mug - Tommy Hilfiger", id = 10214415687 },
    { name = "Hands Behind Back", id = 113307296054375 },
    { name = "SHAKE IT {THE ORIGINAL}", id = 88429342786867 },
    { name = "Cute Kpop Poses - Profile Poses", id = 90929823390861 },
    { name = "Sonic's Spindash", id = 110172609245744 },
    { name = "NO NO PLEASE SIT EMOTE", id = 87936851262558 },
    { name = "OneyPlays Dance", id = 111085939371731 },
    { name = "Spin Around With A Friend Matching", id = 70617440339521 },
    { name = "✅ Obby Head - Original Emote", id = 119008007290744 },
    { name = "[BEST] Nightmail jig crossing the border dance", id = 136328385086605 },
    { name = "xaviersobased", id = 139371349828009 },
    { name = "♡: Cute Shy Sway  ", id = 91342807029640 },
    { name = "Freddy Fazbear", id = 77781675717382 },
    { name = "BOO Emote [MATCHING] Version 1", id = 137681302976475 },
}

-- ========== АНИМАЦИИ ==========
local animCache = {}
local curTrack, prevTrack = nil, nil
local emoteLoop = false
local loopEmote = nil -- запомнить эмоцию для бесконечного повтора

local function LoadAnim(assetId)
    if animCache[assetId] then return animCache[assetId] end
    local animId
    pcall(function()
        local objs = game:GetObjects("rbxassetid://" .. tostring(assetId))
        for _, obj in ipairs(objs) do
            if obj:IsA("Animation") then animId = obj.AnimationId; break end
            local a = obj:FindFirstChildWhichIsA("Animation", true)
            if a then animId = a.AnimationId; break end
            if obj:IsA("KeyframeSequence") then animId = "rbxassetid://" .. tostring(assetId); break end
        end
    end)
    if not animId then
        pcall(function()
            local m = InsertService:LoadAsset(assetId)
            local a = m:FindFirstChildWhichIsA("Animation", true)
            if a then animId = a.AnimationId end
            pcall(function() m:Destroy() end)
        end)
    end
    if not animId then animId = "rbxassetid://" .. tostring(assetId) end
    animCache[assetId] = animId
    return animId
end

local function StopCur()
    if curTrack then pcall(function() curTrack:Stop(0.2) end) end
    curTrack = nil
end
local function StopPrev()
    if prevTrack then pcall(function() prevTrack:Stop(0.15) end) end
    prevTrack = nil
end

local function PlayAnim(emote, preview)
    local ch = LocalPlayer.Character
    if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then animator = Instance.new("Animator", hum) end
    if preview then StopPrev() else StopCur(); StopPrev() end
    local aid = LoadAnim(emote.id)
    local aObj = Instance.new("Animation")
    aObj.AnimationId = aid
    local ok, track = pcall(function() return animator:LoadAnimation(aObj) end)
    if not ok then ok, track = pcall(function() return hum:LoadAnimation(aObj) end) end
    if not ok or not track then return end
    if preview then
        track.Looped = false; track:Play(0.15); track:AdjustSpeed(0.4)
        prevTrack = track
    else
        track.Looped = emoteLoop; track:Play(0.2)
        curTrack = track
        if emoteLoop then
            loopEmote = emote
        else
            loopEmote = nil
        end
    end
end

-- Бесконечный повтор: если Loop включен, при остановке трека принудительно перезапускаем
task.spawn(function()
    while true do
        task.wait(0.3)
        if emoteLoop and loopEmote then
            local ch = LocalPlayer.Character
            if ch then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hum then
                    -- Если трек остановился или персонаж упал/сидит/что угодно — перезапускаем
                    if not curTrack or not curTrack.IsPlaying then
                        PlayAnim(loopEmote, false)
                    end
                end
            end
        end
    end
end)

getgenv().__StopEmote = function() StopCur(); StopPrev(); loopEmote = nil end
getgenv().__EmoteLoop = false

-- ========== ИЗБРАННОЕ ==========
if not getgenv().__EmoteFavs then getgenv().__EmoteFavs = {} end
local Favs = getgenv().__EmoteFavs
local function IsFav(n) for _, v in ipairs(Favs) do if v == n then return true end end return false end
local function TogFav(n) for i, v in ipairs(Favs) do if v == n then table.remove(Favs, i); return end end table.insert(Favs, n) end
local function GetFavList()
    local r = {}
    for _, n in ipairs(Favs) do
        for _, e in ipairs(AllEmotes) do if e.name == n then table.insert(r, e); break end end
    end
    return r
end

-- ========== GUI ==========
if guiParent:FindFirstChild("EmoteWheelX") then guiParent.EmoteWheelX:Destroy() end
local gui = Instance.new("ScreenGui", guiParent)
gui.Name = "EmoteWheelX"; gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true; gui.DisplayOrder = 101

local isOpen = false
local SECTORS = 8
local currentPage = 1
local showFavs = false -- переключатель: все / избранное
local hoveredSector = 0
local searchTxt = ""

local function tw(obj, t, props) return TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props) end
local function corner(p, r) local c = Instance.new("UICorner", p); c.CornerRadius = UDim.new(0, r or 8) end

local function GetSourceList()
    local src
    if showFavs then src = GetFavList() else src = AllEmotes end
    if searchTxt == "" then return src end
    local f = searchTxt:lower()
    local r = {}
    for _, e in ipairs(src) do
        if e.name:lower():find(f, 1, true) then table.insert(r, e) end
    end
    return r
end

local function TotalPages()
    local src = GetSourceList()
    return math.max(1, math.ceil(#src / SECTORS))
end

local function GetPageEmotes()
    local src = GetSourceList()
    local startIdx = (currentPage - 1) * SECTORS + 1
    local result = {}
    for i = startIdx, math.min(startIdx + SECTORS - 1, #src) do
        table.insert(result, src[i])
    end
    return result
end

-- Root overlay
local root = Instance.new("Frame", gui)
root.Size = UDim2.new(1,0,1,0); root.BackgroundTransparency = 1; root.Visible = false; root.ZIndex = 1

local dim = Instance.new("TextButton", root)
dim.Size = UDim2.new(1,0,1,0); dim.BackgroundColor3 = Color3.new(0,0,0)
dim.BackgroundTransparency = 0.6; dim.BorderSizePixel = 0; dim.Text = ""; dim.ZIndex = 1

-- ========== SEARCH BOX (над колесом) ==========
local searchBar = Instance.new("Frame", root)
searchBar.Size = UDim2.new(0, 300, 0, 34)
searchBar.Position = UDim2.new(0.5, -150, 0.5, -250)
searchBar.BackgroundTransparency = 1; searchBar.ZIndex = 10

local sBox = Instance.new("TextBox", searchBar)
sBox.Size = UDim2.new(1, 0, 1, 0)
sBox.BackgroundColor3 = Color3.fromRGB(14, 11, 26); sBox.BackgroundTransparency = 0.05
sBox.TextColor3 = S.textMain; sBox.PlaceholderText = "🔍 Search emotes..."
sBox.PlaceholderColor3 = S.textSoft; sBox.Font = Enum.Font.GothamSemibold
sBox.TextSize = 12; sBox.ClearTextOnFocus = false; sBox.Text = ""
sBox.TextXAlignment = Enum.TextXAlignment.Left; sBox.ZIndex = 12
corner(sBox, 10)
local sBoxStroke = Instance.new("UIStroke", sBox)
sBoxStroke.Color = S.stroke; sBoxStroke.Transparency = 0.4; sBoxStroke.Thickness = 1.5
local sBoxPad = Instance.new("UIPadding", sBox)
sBoxPad.PaddingLeft = UDim.new(0, 10); sBoxPad.PaddingRight = UDim.new(0, 10)

-- ========== WHEEL CONTAINER ==========
local WHEEL_SIZE = 420
local CENTER_SIZE = 120

local wheelFrame = Instance.new("Frame", root)
wheelFrame.Size = UDim2.new(0, WHEEL_SIZE, 0, WHEEL_SIZE)
wheelFrame.Position = UDim2.new(0.5, -WHEEL_SIZE/2, 0.5, -WHEEL_SIZE/2)
wheelFrame.BackgroundTransparency = 1; wheelFrame.ZIndex = 10

-- Создаём 8 секторов как кнопки-трапеции
-- Позиционируем элементы по кругу, каждые 45 градусов
local sectorFrames = {}
local sectorLabels = {}
local sectorNumbers = {}
local sectorFavStars = {}
local sectorThumbs = {}

local RING_RADIUS = 148 -- расстояние от центра до середины сектора
local SECTOR_W = 110
local SECTOR_H = 80

for i = 1, SECTORS do
    local angle = (i - 1) * (360 / SECTORS) - 90 -- начинаем сверху
    local rad = math.rad(angle)
    local cx = WHEEL_SIZE/2 + math.cos(rad) * RING_RADIUS - SECTOR_W/2
    local cy = WHEEL_SIZE/2 + math.sin(rad) * RING_RADIUS - SECTOR_H/2

    local sector = Instance.new("TextButton", wheelFrame)
    sector.Name = "Sector" .. i
    sector.Size = UDim2.new(0, SECTOR_W, 0, SECTOR_H)
    sector.Position = UDim2.new(0, cx, 0, cy)
    sector.BackgroundColor3 = S.sectorNorm
    sector.BackgroundTransparency = 0.15
    sector.BorderSizePixel = 0
    sector.Text = ""
    sector.ZIndex = 12
    sector.AutoButtonColor = false

    local sCorner = Instance.new("UICorner", sector)
    sCorner.CornerRadius = UDim.new(0, 12)

    local sStroke = Instance.new("UIStroke", sector)
    sStroke.Color = S.stroke; sStroke.Transparency = 0.4; sStroke.Thickness = 1.5

    -- Номер сектора (маленький, в углу)
    local numLbl = Instance.new("TextLabel", sector)
    numLbl.Size = UDim2.new(0, 18, 0, 16)
    numLbl.Position = UDim2.new(0, 4, 0, 2)
    numLbl.BackgroundTransparency = 1
    numLbl.Text = tostring(i)
    numLbl.TextColor3 = S.accent
    numLbl.Font = Enum.Font.GothamBold; numLbl.TextSize = 11
    numLbl.ZIndex = 14

    -- Thumbnail (иконка эмоции)
    local thumb = Instance.new("ImageLabel", sector)
    thumb.Size = UDim2.new(0, 36, 0, 36)
    thumb.Position = UDim2.new(0.5, -18, 0, 4)
    thumb.BackgroundTransparency = 1
    thumb.Image = ""
    thumb.ScaleType = Enum.ScaleType.Fit
    thumb.ZIndex = 14

    -- Название эмоции
    local nameLbl = Instance.new("TextLabel", sector)
    nameLbl.Size = UDim2.new(1, -8, 0, 14)
    nameLbl.Position = UDim2.new(0, 4, 1, -18)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = ""
    nameLbl.TextColor3 = S.textMain
    nameLbl.Font = Enum.Font.GothamSemibold; nameLbl.TextSize = 8
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.ZIndex = 14

    -- Звёздочка избранного
    local favStar = Instance.new("TextButton", sector)
    favStar.Size = UDim2.new(0, 18, 0, 18)
    favStar.Position = UDim2.new(1, -20, 0, 1)
    favStar.BackgroundTransparency = 1
    favStar.Text = "☆"
    favStar.TextColor3 = S.textSoft
    favStar.Font = Enum.Font.GothamBold; favStar.TextSize = 12
    favStar.ZIndex = 16

    sectorFrames[i] = sector
    sectorLabels[i] = nameLbl
    sectorNumbers[i] = numLbl
    sectorFavStars[i] = favStar
    sectorThumbs[i] = thumb
end

-- ========== ЦЕНТР КОЛЕСА ==========
local centerCircle = Instance.new("Frame", wheelFrame)
centerCircle.Size = UDim2.new(0, CENTER_SIZE, 0, CENTER_SIZE)
centerCircle.Position = UDim2.new(0.5, -CENTER_SIZE/2, 0.5, -CENTER_SIZE/2)
centerCircle.BackgroundColor3 = S.center
centerCircle.BackgroundTransparency = 0.05
centerCircle.ZIndex = 15

local ccCorner = Instance.new("UICorner", centerCircle)
ccCorner.CornerRadius = UDim.new(0.5, 0)

local ccStroke = Instance.new("UIStroke", centerCircle)
ccStroke.Color = S.accent; ccStroke.Transparency = 0.25; ccStroke.Thickness = 2

-- Текст в центре
local centerText = Instance.new("TextLabel", centerCircle)
centerText.Size = UDim2.new(1, -10, 0, 30)
centerText.Position = UDim2.new(0, 5, 0.5, -22)
centerText.BackgroundTransparency = 1
centerText.Text = "Select an\nEmote"
centerText.TextColor3 = S.centerText
centerText.Font = Enum.Font.GothamBold; centerText.TextSize = 12
centerText.TextWrapped = true
centerText.ZIndex = 16

-- Страница (в центре, ниже названия)
local pageLbl = Instance.new("TextLabel", centerCircle)
pageLbl.Size = UDim2.new(1, 0, 0, 14)
pageLbl.Position = UDim2.new(0, 0, 0.5, 10)
pageLbl.BackgroundTransparency = 1
pageLbl.Text = "1 / 1"
pageLbl.TextColor3 = S.textSoft
pageLbl.Font = Enum.Font.GothamSemibold; pageLbl.TextSize = 10
pageLbl.ZIndex = 16

-- ========== КНОПКИ ПОД КОЛЕСОМ ==========
local bottomBar = Instance.new("Frame", root)
bottomBar.Size = UDim2.new(0, 420, 0, 82)
bottomBar.Position = UDim2.new(0.5, -210, 0.5, WHEEL_SIZE/2 + 12)
bottomBar.BackgroundTransparency = 1; bottomBar.ZIndex = 10

-- Стрелка влево
local prevBtn = Instance.new("TextButton", bottomBar)
prevBtn.Size = UDim2.new(0, 44, 0, 36)
prevBtn.Position = UDim2.new(0, 0, 0, 0)
prevBtn.BackgroundColor3 = S.pageBg; prevBtn.BackgroundTransparency = 0.1
prevBtn.Text = "◀"; prevBtn.TextColor3 = S.textMain
prevBtn.Font = Enum.Font.GothamBold; prevBtn.TextSize = 18; prevBtn.ZIndex = 12
corner(prevBtn, 8)
Instance.new("UIStroke", prevBtn).Color = S.stroke

-- Стрелка вправо
local nextBtn = Instance.new("TextButton", bottomBar)
nextBtn.Size = UDim2.new(0, 44, 0, 36)
nextBtn.Position = UDim2.new(0, 50, 0, 0)
nextBtn.BackgroundColor3 = S.pageBg; nextBtn.BackgroundTransparency = 0.1
nextBtn.Text = "▶"; nextBtn.TextColor3 = S.textMain
nextBtn.Font = Enum.Font.GothamBold; nextBtn.TextSize = 18; nextBtn.ZIndex = 12
corner(nextBtn, 8)
Instance.new("UIStroke", nextBtn).Color = S.stroke

-- Кнопка Loop
local loopBtn = Instance.new("TextButton", bottomBar)
loopBtn.Size = UDim2.new(0, 80, 0, 36)
loopBtn.Position = UDim2.new(0, 104, 0, 0)
loopBtn.BackgroundColor3 = S.pageBg; loopBtn.BackgroundTransparency = 0.1
loopBtn.Text = "🔁 OFF"; loopBtn.TextColor3 = S.loopOff
loopBtn.Font = Enum.Font.GothamBold; loopBtn.TextSize = 11; loopBtn.ZIndex = 12
corner(loopBtn, 8)
local loopStroke = Instance.new("UIStroke", loopBtn)
loopStroke.Color = S.stroke

-- Кнопка Favorites
local favBtn = Instance.new("TextButton", bottomBar)
favBtn.Size = UDim2.new(0, 80, 0, 36)
favBtn.Position = UDim2.new(0, 192, 0, 0)
favBtn.BackgroundColor3 = S.pageBg; favBtn.BackgroundTransparency = 0.1
favBtn.Text = "★ Favs"; favBtn.TextColor3 = S.textSoft
favBtn.Font = Enum.Font.GothamBold; favBtn.TextSize = 11; favBtn.ZIndex = 12
corner(favBtn, 8)
local favStroke = Instance.new("UIStroke", favBtn)
favStroke.Color = S.stroke

-- Кнопка Stop
local stopBtn = Instance.new("TextButton", bottomBar)
stopBtn.Size = UDim2.new(0, 56, 0, 36)
stopBtn.Position = UDim2.new(0, 280, 0, 0)
stopBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 30); stopBtn.BackgroundTransparency = 0.1
stopBtn.Text = "STOP"; stopBtn.TextColor3 = S.danger
stopBtn.Font = Enum.Font.GothamBold; stopBtn.TextSize = 11; stopBtn.ZIndex = 12
corner(stopBtn, 8)
Instance.new("UIStroke", stopBtn).Color = S.danger

-- Кнопка Random
local randBtn = Instance.new("TextButton", bottomBar)
randBtn.Size = UDim2.new(0, 36, 0, 36)
randBtn.Position = UDim2.new(0, 344, 0, 0)
randBtn.BackgroundColor3 = S.pageBg; randBtn.BackgroundTransparency = 0.1
randBtn.Text = "🎲"; randBtn.TextColor3 = S.textMain
randBtn.Font = Enum.Font.GothamBold; randBtn.TextSize = 16; randBtn.ZIndex = 12
corner(randBtn, 8)
Instance.new("UIStroke", randBtn).Color = S.stroke

-- Кнопка Close (X)
local closeBtn = Instance.new("TextButton", bottomBar)
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(0, 384, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 30); closeBtn.BackgroundTransparency = 0.1
closeBtn.Text = "✕"; closeBtn.TextColor3 = S.danger
closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 14; closeBtn.ZIndex = 12
corner(closeBtn, 8)
Instance.new("UIStroke", closeBtn).Color = S.danger

-- ========== ROW 2: Export / Import ==========
local exportBtn = Instance.new("TextButton", bottomBar)
exportBtn.Size = UDim2.new(0, 100, 0, 32)
exportBtn.Position = UDim2.new(0, 0, 0, 42)
exportBtn.BackgroundColor3 = S.pageBg; exportBtn.BackgroundTransparency = 0.1
exportBtn.Text = "📤 Export"; exportBtn.TextColor3 = S.textMain
exportBtn.Font = Enum.Font.GothamBold; exportBtn.TextSize = 11; exportBtn.ZIndex = 12
corner(exportBtn, 8)
Instance.new("UIStroke", exportBtn).Color = S.stroke

local importBox = Instance.new("TextBox", bottomBar)
importBox.Size = UDim2.new(0, 210, 0, 32)
importBox.Position = UDim2.new(0, 106, 0, 42)
importBox.BackgroundColor3 = Color3.fromRGB(14, 11, 26); importBox.BackgroundTransparency = 0.05
importBox.TextColor3 = S.textMain; importBox.PlaceholderText = "Paste favorites code..."
importBox.PlaceholderColor3 = S.textSoft; importBox.Font = Enum.Font.GothamSemibold
importBox.TextSize = 10; importBox.ClearTextOnFocus = true; importBox.Text = ""
importBox.TextXAlignment = Enum.TextXAlignment.Left; importBox.ZIndex = 12
corner(importBox, 8)
local ibStroke = Instance.new("UIStroke", importBox)
ibStroke.Color = S.stroke; ibStroke.Transparency = 0.4
local ibPad = Instance.new("UIPadding", importBox)
ibPad.PaddingLeft = UDim.new(0, 8); ibPad.PaddingRight = UDim.new(0, 8)

local importBtn = Instance.new("TextButton", bottomBar)
importBtn.Size = UDim2.new(0, 100, 0, 32)
importBtn.Position = UDim2.new(0, 320, 0, 42)
importBtn.BackgroundColor3 = S.pageBg; importBtn.BackgroundTransparency = 0.1
importBtn.Text = "📥 Import"; importBtn.TextColor3 = S.textMain
importBtn.Font = Enum.Font.GothamBold; importBtn.TextSize = 11; importBtn.ZIndex = 12
corner(importBtn, 8)
Instance.new("UIStroke", importBtn).Color = S.stroke

-- Export: кодируем избранное в строку и копируем в буфер обмена
exportBtn.MouseButton1Click:Connect(function()
    if #Favs == 0 then
        SendNotify("No favorites to export!")
        return
    end
    -- Формат: имена через |||
    local encoded = table.concat(Favs, "|||")
    if setclipboard then
        setclipboard(encoded)
        SendNotify("Favorites copied! (" .. #Favs .. " emotes)")
    elseif toclipboard then
        toclipboard(encoded)
        SendNotify("Favorites copied! (" .. #Favs .. " emotes)")
    else
        -- Fallback: показать в importBox для ручного копирования
        importBox.Text = encoded
        SendNotify("Copy the text from the box!")
    end
end)

-- Import: декодируем строку и заменяем избранное
importBtn.MouseButton1Click:Connect(function()
    local raw = importBox.Text
    if raw == "" then
        SendNotify("Paste a favorites code first!")
        return
    end
    local newFavs = {}
    for name in raw:gmatch("([^|]+)") do
        local trimmed = name:match("^%s*(.-)%s*$")
        if trimmed and trimmed ~= "" then
            -- Проверяем что эмоция существует
            for _, e in ipairs(AllEmotes) do
                if e.name == trimmed then
                    -- Не дублируем
                    local found = false
                    for _, f in ipairs(newFavs) do if f == trimmed then found = true; break end end
                    if not found then table.insert(newFavs, trimmed) end
                    break
                end
            end
        end
    end
    if #newFavs == 0 then
        SendNotify("No valid emotes found in code!")
        return
    end
    -- Заменяем
    getgenv().__EmoteFavs = newFavs
    Favs = getgenv().__EmoteFavs
    importBox.Text = ""
    SendNotify("Imported " .. #newFavs .. " favorites!")
    if RefreshWheel then RefreshWheel() end
end)

-- ========== ОБНОВЛЕНИЕ КОЛЕСА ==========
local function Thumb(id) return "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=150&h=150" end

local function RefreshWheel()
    local emotes = GetPageEmotes()
    local total = TotalPages()
    pageLbl.Text = currentPage .. " / " .. total
    -- Показываем кол-во найденных при поиске
    if searchTxt ~= "" then
        local count = #GetSourceList()
        pageLbl.Text = currentPage .. "/" .. total .. " (" .. count .. ")" 
    end

    for i = 1, SECTORS do
        local emote = emotes[i]
        if emote then
            sectorFrames[i].Visible = true
            sectorLabels[i].Text = emote.name
            sectorThumbs[i].Image = Thumb(emote.id)
            sectorFavStars[i].Text = IsFav(emote.name) and "★" or "☆"
            sectorFavStars[i].TextColor3 = IsFav(emote.name) and S.fav or S.textSoft
        else
            sectorFrames[i].Visible = false
            sectorLabels[i].Text = ""
            sectorThumbs[i].Image = ""
        end
        -- Сброс подсветки
        sectorFrames[i].BackgroundColor3 = S.sectorNorm
        sectorFrames[i].BackgroundTransparency = 0.15
    end
end

-- Подключаем поиск к RefreshWheel (после определения функции)
sBox:GetPropertyChangedSignal("Text"):Connect(function()
    searchTxt = sBox.Text
    currentPage = 1
    local total = TotalPages()
    if currentPage > total then currentPage = total end
    RefreshWheel()
end)

-- ========== HOVER И КЛИК СЕКТОРОВ ==========
for i = 1, SECTORS do
    sectorFrames[i].MouseEnter:Connect(function()
        hoveredSector = i
        tw(sectorFrames[i], 0.1, {BackgroundColor3 = S.sectorHov, BackgroundTransparency = 0}):Play()
        sectorFrames[i]:FindFirstChildOfClass("UIStroke").Color = S.accent
        sectorFrames[i]:FindFirstChildOfClass("UIStroke").Transparency = 0
        -- Превью
        local emotes = GetPageEmotes()
        if emotes[i] then
            centerText.Text = emotes[i].name
            centerText.TextSize = 10
            PlayAnim(emotes[i], true)
        end
    end)

    sectorFrames[i].MouseLeave:Connect(function()
        if hoveredSector == i then hoveredSector = 0 end
        tw(sectorFrames[i], 0.12, {BackgroundColor3 = S.sectorNorm, BackgroundTransparency = 0.15}):Play()
        sectorFrames[i]:FindFirstChildOfClass("UIStroke").Color = S.stroke
        sectorFrames[i]:FindFirstChildOfClass("UIStroke").Transparency = 0.4
        StopPrev()
        centerText.Text = "Select an\nEmote"
        centerText.TextSize = 12
    end)

    sectorFrames[i].MouseButton1Click:Connect(function()
        local emotes = GetPageEmotes()
        if emotes[i] then
            StopPrev()
            PlayAnim(emotes[i], false)
            -- Закрываем колесо после выбора
            task.delay(0.05, function()
                isOpen = false
                root.Visible = false
                StopPrev()
            end)
        end
    end)

    -- Избранное: клик по звёздочке
    sectorFavStars[i].MouseButton1Click:Connect(function()
        local emotes = GetPageEmotes()
        if emotes[i] then
            TogFav(emotes[i].name)
            sectorFavStars[i].Text = IsFav(emotes[i].name) and "★" or "☆"
            sectorFavStars[i].TextColor3 = IsFav(emotes[i].name) and S.fav or S.textSoft
        end
    end)
end

-- ========== УПРАВЛЕНИЕ СТРАНИЦАМИ ==========
local function GoPage(delta)
    local total = TotalPages()
    currentPage = currentPage + delta
    if currentPage < 1 then currentPage = total end
    if currentPage > total then currentPage = 1 end
    RefreshWheel()
end

prevBtn.MouseButton1Click:Connect(function() GoPage(-1) end)
nextBtn.MouseButton1Click:Connect(function() GoPage(1) end)

-- ========== LOOP ==========
loopBtn.MouseButton1Click:Connect(function()
    emoteLoop = not emoteLoop
    getgenv().__EmoteLoop = emoteLoop
    if emoteLoop then
        loopBtn.Text = "🔁 ON"
        loopBtn.TextColor3 = S.loopOn
        loopStroke.Color = S.loopOn
        if curTrack then curTrack.Looped = true end
    else
        loopBtn.Text = "🔁 OFF"
        loopBtn.TextColor3 = S.loopOff
        loopStroke.Color = S.stroke
        loopEmote = nil
        if curTrack then curTrack.Looped = false end
    end
end)

-- ========== FAVORITES TAB ==========
favBtn.MouseButton1Click:Connect(function()
    showFavs = not showFavs
    if showFavs then
        favBtn.TextColor3 = S.fav
        favStroke.Color = S.fav
        favBtn.Text = "★ Favs"
    else
        favBtn.TextColor3 = S.textSoft
        favStroke.Color = S.stroke
        favBtn.Text = "★ Favs"
    end
    -- При переключении вкладок: НЕ сбрасываем страницу на 1
    -- Но ограничиваем, если текущая страница больше чем есть
    local total = TotalPages()
    if currentPage > total then currentPage = total end
    RefreshWheel()
end)

-- ========== STOP ==========
stopBtn.MouseButton1Click:Connect(function()
    StopCur()
    StopPrev()
    loopEmote = nil
end)

-- ========== RANDOM ==========
local randomLoopActive = false

randBtn.MouseButton1Click:Connect(function()
    local src = GetSourceList()
    if #src == 0 then return end

    -- Если уже крутится рандомный цикл — выключаем
    if randomLoopActive then
        randomLoopActive = false
        StopCur(); StopPrev(); loopEmote = nil
        randBtn.Text = "🎲"
        SendNotify("Random stopped")
        return
    end

    randomLoopActive = true
    randBtn.Text = "⏹"
    -- Закрываем колесо
    task.delay(0.05, function()
        isOpen = false
        root.Visible = false
        StopPrev()
    end)

    -- Фоновый цикл: рандомная эмоция на рандомное время
    task.spawn(function()
        while randomLoopActive do
            local e = src[math.random(1, #src)]
            PlayAnim(e, false)
            local duration = math.random(3, 15) -- от 3 до 15 секунд
            local waited = 0
            while waited < duration and randomLoopActive do
                task.wait(0.3)
                waited = waited + 0.3
            end
            if randomLoopActive then
                StopCur()
            end
        end
    end)
end)

-- ========== CLOSE ==========
local function Close()
    isOpen = false
    root.Visible = false
    StopPrev()
end

closeBtn.MouseButton1Click:Connect(Close)
dim.MouseButton1Click:Connect(Close)

-- ========== TOGGLE ==========
local function Toggle()
    if isOpen then Close(); return end
    isOpen = true
    root.Visible = true
    hoveredSector = 0
    centerText.Text = "Select an\nEmote"
    centerText.TextSize = 12
    -- Сброс поиска при открытии
    searchTxt = ""; sBox.Text = ""
    -- Страница НЕ сбрасывается — помним где были
    local total = TotalPages()
    if currentPage > total then currentPage = total end
    RefreshWheel()
end

getgenv().__ToggleEmoteWheel = Toggle
getgenv().__StopEmote = function() StopCur(); StopPrev(); loopEmote = nil end

-- ========== КЛАВИШИ ==========
UserInputService.InputBegan:Connect(function(input, gpe)
    -- '.' (Period) — ВСЕГДА перехватываем, даже если gpe=true (Roblox CoreGui тоже его ловит)
    if input.KeyCode == Enum.KeyCode.Period then Toggle(); return end
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Escape and isOpen then Close() end
    -- Цифры 1-8 для быстрого выбора сектора (когда колесо открыто)
    if isOpen then
        local num = nil
        if input.KeyCode == Enum.KeyCode.One then num = 1
        elseif input.KeyCode == Enum.KeyCode.Two then num = 2
        elseif input.KeyCode == Enum.KeyCode.Three then num = 3
        elseif input.KeyCode == Enum.KeyCode.Four then num = 4
        elseif input.KeyCode == Enum.KeyCode.Five then num = 5
        elseif input.KeyCode == Enum.KeyCode.Six then num = 6
        elseif input.KeyCode == Enum.KeyCode.Seven then num = 7
        elseif input.KeyCode == Enum.KeyCode.Eight then num = 8
        end
        if num then
            local emotes = GetPageEmotes()
            if emotes[num] then
                StopPrev()
                PlayAnim(emotes[num], false)
                Close()
            end
        end
        -- Q/E для перелистывания страниц
        if input.KeyCode == Enum.KeyCode.Q then GoPage(-1) end
        if input.KeyCode == Enum.KeyCode.E then GoPage(1) end
    end
end)

-- Скролл мышью по колесу для перелистывания
wheelFrame.InputChanged:Connect(function(input)
    if not isOpen then return end
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        if input.Position.Z > 0 then
            GoPage(-1)
        else
            GoPage(1)
        end
    end
end)

-- ========== RESPAWN ==========
LocalPlayer.CharacterAdded:Connect(function()
    curTrack = nil; prevTrack = nil
    -- Если Loop включен — перезапустить эмоцию через секунду после респавна
    if emoteLoop and loopEmote then
        task.delay(1, function()
            PlayAnim(loopEmote, false)
        end)
    end
end)

-- Init
root.Visible = false
RefreshWheel()
SendNotify("Emote Wheel: " .. #AllEmotes .. " emotes. Press '.' | Q/E pages | 1-8 select")
print("[Emote Wheel] " .. #AllEmotes .. " emotes loaded. Toggle: '.' | Q/E = pages | 1-8 = select | Scroll = pages")
