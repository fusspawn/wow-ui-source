---------------
--NOTE - Please do not change this section without talking to Jacob
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;
tbl.SecureCapsuleGet = SecureCapsuleGet;

local function Import(name)
	tbl[name] = tbl.SecureCapsuleGet(name);
end

Import("IsOnGlueScreen");

if ( tbl.IsOnGlueScreen() ) then
	tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
end

-- REMOVE BEFORE SHIP
tbl.print = print;
tbl.setmetatable = setmetatable;
setfenv(1, tbl);
----------------

--Local references to frames
local StoreFrame;
local StoreConfirmationFrame;
local StoreTooltip;

--Local variables (here instead of as members on frames for now)
local JustOrderedProduct = false;
local WaitingOnConfirmation = false;

--Imports
Import("C_PurchaseAPI");
Import("C_PetJournal");
Import("CreateForbiddenFrame");
Import("IsGMClient");
Import("math");
Import("pairs");
Import("select");
Import("tostring");
Import("tonumber");
Import("unpack");
Import("LoadURLIndex");
Import("GetContainerNumFreeSlots");
Import("GetCursorPosition");
Import("PlaySound");
Import("SetPortraitToTexture");
Import("BACKPACK_CONTAINER");
Import("NUM_BAG_SLOTS");

--GlobalStrings
Import("BLIZZARD_STORE");
Import("BLIZZARD_STORE_ON_SALE");
Import("BLIZZARD_STORE_BUY");
Import("BLIZZARD_STORE_PLUS_TAX");
Import("BLIZZARD_STORE_PRODUCT_INDEX");
Import("BLIZZARD_STORE_CANCEL_PURCHASE");
Import("BLIZZARD_STORE_FINAL_BUY");
Import("BLIZZARD_STORE_CONFIRMATION_TITLE");
Import("BLIZZARD_STORE_CONFIRMATION_INSTRUCTION");
Import("BLIZZARD_STORE_FINAL_PRICE_LABEL");
Import("BLIZZARD_STORE_PAYMENT_METHOD");
Import("BLIZZARD_STORE_PAYMENT_METHOD_EXTRA");
Import("BLIZZARD_STORE_LOADING");
Import("BLIZZARD_STORE_PLEASE_WAIT");
Import("BLIZZARD_STORE_NO_ITEMS");
Import("BLIZZARD_STORE_CHECK_BACK_LATER");
Import("BLIZZARD_STORE_TRANSACTION_IN_PROGRESS");
Import("BLIZZARD_STORE_CONNECTING");
Import("BLIZZARD_STORE_VISIT_WEBSITE");
Import("BLIZZARD_STORE_VISIT_WEBSITE_WARNING");
Import("BLIZZARD_STORE_BAG_FULL");
Import("BLIZZARD_STORE_BAG_FULL_DESC");
Import("BLIZZARD_STORE_CONFIRMATION_GENERIC");
Import("BLIZZARD_STORE_CONFIRMATION_TEST");
Import("BLIZZARD_STORE_BROWSE_TEST_CURRENCY");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_USD");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_KRW_LONG");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_CPT_LONG");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_TPT");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_GBP");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_EURO");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_RUB");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_MXN");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_BRL");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_ARS");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_CLP");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_AUD");
Import("BLIZZARD_STORE_CURRENCY_RAW_ASTERISK");
Import("BLIZZARD_STORE_CURRENCY_BETA");
Import("BLIZZARD_STORE_BROWSE_BATTLE_COINS_KR");
Import("BLIZZARD_STORE_BROWSE_BATTLE_COINS_CN");
Import("BLIZZARD_STORE_ASTERISK");
Import("BLIZZARD_STORE_INTERNAL_ERROR");
Import("BLIZZARD_STORE_INTERNAL_ERROR_SUBTEXT");
Import("BLIZZARD_STORE_ERROR_TITLE_OTHER");
Import("BLIZZARD_STORE_ERROR_MESSAGE_OTHER");
Import("BLIZZARD_STORE_NOT_AVAILABLE");
Import("BLIZZARD_STORE_NOT_AVAILABLE_SUBTEXT");
Import("BLIZZARD_STORE_ERROR_TITLE_PAYMENT");
Import("BLIZZARD_STORE_ERROR_MESSAGE_PAYMENT");
Import("BLIZZARD_STORE_ERROR_TITLE_BATTLEPAY_DISABLED");
Import("BLIZZARD_STORE_ERROR_MESSAGE_BATTLEPAY_DISABLED");
Import("BLIZZARD_STORE_SECOND_CHANCE_KR");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_CN");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_TW");
Import("BLIZZARD_STORE_REGION_LOCKED");
Import("BLIZZARD_STORE_REGION_LOCKED_SUBTEXT");
Import("BLIZZARD_STORE_ERROR_TITLE_INSUFFICIENT_BALANCE");
Import("BLIZZARD_STORE_ERROR_MESSAGE_INSUFFICIENT_BALANCE");
Import("BLIZZARD_STORE_DISCOUNT_TEXT_FORMAT");
Import("BLIZZARD_STORE_PAGE_NUMBER");

Import("OKAY");
Import("LARGE_NUMBER_SEPERATOR");
Import("DECIMAL_SEPERATOR");

--Lua enums
Import("LE_STORE_ERROR_INVALID_PAYMENT_METHOD");
Import("LE_STORE_ERROR_PAYMENT_FAILED");
Import("LE_STORE_ERROR_WRONG_CURRENCY");
Import("LE_STORE_ERROR_BATTLEPAY_DISABLED");
Import("LE_STORE_ERROR_INSUFFICIENT_BALANCE");
Import("LE_STORE_ERROR_OTHER");

BLIZZARD_STORE_SPLASH_BANNER_DISCOUNT_FORMAT = "%d%% OFF!";
BLIZZARD_STORE_SPLASH_BANNER_FREE = "FREE!";
BLIZZARD_STORE_SPLASH_BANNER_FEATURED = "FEATURED!";
BLIZZARD_STORE_PRICE_FREE = "|cff00ff00FREE!|r";
BLIZZARD_STORE_CLAIM = "Claim Now";

BLIZZARD_STORE_BUY = "Buy Now";

--Data
local CURRENCY_UNKNOWN = 0;
local CURRENCY_USD = 1;
local CURRENCY_GBP = 2;
local CURRENCY_KRW = 3;
local CURRENCY_EUR = 4;
local CURRENCY_RUB = 5;
local CURRENCY_ARS = 8;
local CURRENCY_CLP = 9;
local CURRENCY_MXN = 10;
local CURRENCY_BRL = 11;
local CURRENCY_AUD = 12;
local CURRENCY_CPT = 14;
local CURRENCY_TPT = 15;
local CURRENCY_BETA = 16;
local NUM_STORE_PRODUCT_CARDS = 8;
local NUM_STORE_PRODUCT_CARDS_PER_ROW = 4;
local NUM_STORE_CATEGORIES = 4;
local NUM_STORE_SUBCATEGORIES = 3;
local ROTATIONS_PER_SECOND = .5;
local MODELFRAME_DRAG_ROTATION_CONSTANT = 0.010;
local BATTLEPAY_GROUP_DISPLAY_DEFAULT = 0;
local BATTLEPAY_GROUP_DISPLAY_SPLASH = 1;
local PI = math.pi;

local currencyMult = 100;

local selectedCategoryId;
local selectedEntryID;
local selectedPageNum = 1;

--DECIMAL_SEPERATOR = ",";
--LARGE_NUMBER_SEPERATOR = ".";

local function formatLargeNumber(amount)
	amount = tostring(amount);
	local newDisplay = "";
	local strlen = amount:len();
	--Add each thing behind a comma
	for i=4, strlen, 3 do
		newDisplay = LARGE_NUMBER_SEPERATOR..amount:sub(-(i - 1), -(i - 3))..newDisplay;
	end
	--Add everything before the first comma
	newDisplay = amount:sub(1, (strlen % 3 == 0) and 3 or (strlen % 3))..newDisplay;
	return newDisplay;
end

local function largeAmount(num)
	return formatLargeNumber(math.floor(num / currencyMult));
end

local function formatCurrency(dollars, cents, alwaysShowCents)
	if ( alwaysShowCents or cents ~= 0 ) then
		return ("%s%s%02d"):format(formatLargeNumber(dollars), DECIMAL_SEPERATOR, cents);
	else
		return formatLargeNumber(dollars);
	end
end

local function currencyFormatUSD(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_USD:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatGBP(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_GBP:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatKRWLong(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_KRW_LONG:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatEuro(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_EURO:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatRUB(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_RUB:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatARS(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_ARS:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatCLP(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_CLP:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatMXN(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_MXN:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatBRL(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_BRL:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatAUD(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_AUD:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatCPTLong(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_CPT_LONG:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatTPT(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_TPT:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatRawStar(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_RAW_ASTERISK:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatBeta(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_BETA:format(formatCurrency(dollars, cents, true));
end

----------
--Values
---
--formatShort - The format function for currency on the browse window next to quantity display
--formatLong - The format function for currency in areas where we want the full display (e.g. bottom of the browse window and the confirmation frame)
--browseNotice - The notice in the bottom left corner of the browse frame
--confirmationNotice - The notice in the middle of the confirmation frame (between the icon/name and the price
--paymentMethodText - The header displayed on the confirmation frame below the parchment
--paymentMethodSubtext - The smaller text displayed on the confirmation frame below the parchment (and below the paymentMethodText)
--licenseAcceptText - The text (HTML) displayed right above the purchase button on the confirmation window. Can include links.
--requireLicenseAccept - Boolean indicating whether people are required to click a checkbox next to the licenseAcceptText before purchasing the item.
----------
local currencySpecific = {
	[CURRENCY_USD] = {
		formatShort = currencyFormatUSD,
		formatLong = currencyFormatUSD,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
	},
	[CURRENCY_GBP] = {
		formatShort = currencyFormatGBP,
		formatLong = currencyFormatGBP,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		requireLicenseAccept = true,
		browseHasStar = true,
	},
	[CURRENCY_KRW] = {
		formatShort = currencyFormatRawStar,
		formatLong = currencyFormatKRWLong,
		browseNotice = BLIZZARD_STORE_BROWSE_BATTLE_COINS_KR,
		confirmationNotice = BLIZZARD_STORE_SECOND_CHANCE_KR,
		browseWarning = BLIZZARD_STORE_SECOND_CHANCE_KR,
		paymentMethodText = "",
		paymentMethodSubtext = "",
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT,
		requireLicenseAccept = true,
		browseHasStar = false,
	},
	[CURRENCY_EUR] = {
		formatShort = currencyFormatEuro,
		formatLong = currencyFormatEuro,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		requireLicenseAccept = true,
		browseHasStar = true,
	},
	[CURRENCY_RUB] = {
		formatShort = currencyFormatRUB,
		formatLong = currencyFormatRUB,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
	},
	[CURRENCY_ARS] = {
		formatShort = currencyFormatARS,
		formatLong = currencyFormatARS,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
	},
	[CURRENCY_CLP] = {
		formatShort = currencyFormatCLP,
		formatLong = currencyFormatCLP,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
	},
	[CURRENCY_MXN] = {
		formatShort = currencyFormatMXN,
		formatLong = currencyFormatMXN,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
	},
	[CURRENCY_BRL] = {
		formatShort = currencyFormatBRL,
		formatLong = currencyFormatBRL,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
	},
	[CURRENCY_AUD] = {
		formatShort = currencyFormatAUD,
		formatLong = currencyFormatAUD,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
	},
	[CURRENCY_CPT] = {
		formatShort = currencyFormatRawStar,
		formatLong = currencyFormatCPTLong,
		browseNotice = BLIZZARD_STORE_BROWSE_BATTLE_COINS_CN,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_CN,
		paymentMethodText = "",
		paymentMethodSubtext = "",
		browseHasStar = false,
	},
	[CURRENCY_TPT] = {
		formatShort = currencyFormatTPT,
		formatLong = currencyFormatTPT,
		browseNotice = "",
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_TW,
		paymentMethodText = "",
		paymentMethodSubtext = "",
		browseHasStar = false,
	},
	[CURRENCY_BETA] = {
		formatShort = currencyFormatBeta,
		formatLong = currencyFormatBeta,
		browseNotice = BLIZZARD_STORE_BROWSE_TEST_CURRENCY,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_TEST,
		paymentMethodText = BLIZZARD_STORE_CONFIRMATION_TEST,
		paymentMethodSubtext = "",
		browseHasStar = true,
	},
};

local function currencyInfo()
	local currency = C_PurchaseAPI.GetCurrencyID();
	local info = currencySpecific[currency];
	return info;
end

--Error message data
local errorData = {
	[LE_STORE_ERROR_INVALID_PAYMENT_METHOD] = {
		title = BLIZZARD_STORE_ERROR_TITLE_PAYMENT,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_PAYMENT,
		link = 11,
	},
	[LE_STORE_ERROR_PAYMENT_FAILED] = {
		title = BLIZZARD_STORE_ERROR_TITLE_PAYMENT,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_PAYMENT,
		link = 11,
	},
	[LE_STORE_ERROR_WRONG_CURRENCY] = {
		title = BLIZZARD_STORE_ERROR_TITLE_PAYMENT,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_PAYMENT,
		link = 11,
	},
	[LE_STORE_ERROR_BATTLEPAY_DISABLED] = {
		title = BLIZZARD_STORE_ERROR_TITLE_BATTLEPAY_DISABLED,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_BATTLEPAY_DISABLED,
	},
	[LE_STORE_ERROR_INSUFFICIENT_BALANCE] = {
		title = BLIZZARD_STORE_ERROR_TITLE_INSUFFICIENT_BALANCE,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_INSUFFICIENT_BALANCE,
		link = 11,
	},
	[LE_STORE_ERROR_OTHER] = {
		title = BLIZZARD_STORE_ERROR_TITLE_OTHER,	--Probably want to format in the error code
		msg = BLIZZARD_STORE_ERROR_MESSAGE_OTHER,
	}
};

--Code
local function getIndex(tbl, value)
	for k, v in pairs(tbl) do
		if ( v == value ) then
			return k;
		end
	end
end

function StoreFrame_UpdateCard(card,entryID,discountReset)
	local productID, _, _, _, bannerType, normalDollars, normalCents, currentDollars, currentCents, buyableHere, name, description, displayID, texture = C_PurchaseAPI.GetEntryInfo(entryID);
	StoreProductCard_ResetCard(card);

	local info = currencyInfo();

	if (not info) then 
		card:Hide(); 
		return;
	end

	local currencyFormat = info.formatShort;
	local discountAmount, new, hot;
	local discount = false;

	local isFree = false;

	if (currentDollars ~= normalDollars or currentCents ~= normalCents) then
		local normalPrice = normalDollars + (normalCents/100);
		local discountPrice = currentDollars + (currentCents/100);
		local diff = normalPrice - discountPrice;
		discountAmount = math.floor((diff/normalPrice) * 100);
		discount = true;
	end

	if ( card.NewTexture and new ) then
		card.NewTexture:Show();
	elseif ( card.HotTexture and hot ) then
		card.HotTexture:Show();
	elseif ( card.DiscountTexture and discountAmount ) then
		card.DiscountTexture:Show();
		card.DiscountLeft:Show();
		card.DiscountRight:Show();
		card.DiscountText:SetText(BLIZZARD_STORE_DISCOUNT_TEXT_FORMAT:format(discountAmount));
		card.DiscountText:Show();
	end

	if (card.BuyButton) then
		card.BuyButton:SetText(BLIZZARD_STORE_BUY);
	end
	
	if (currentDollars == 0 and currentCents == 0) then
		isFree = true;
		card.CurrentPrice:SetText(BLIZZARD_STORE_PRICE_FREE);
		if (card.BuyButton) then
			card.BuyButton:SetText(BLIZZARD_STORE_CLAIM);
		end
	else
		card.CurrentPrice:SetText(currencyFormat(currentDollars, currentCents));
	end
	

	if ( card.SplashBannerText ) then
		--[[if ( bannerType ) then
			card.SplashBannerText:SetText(bannerText);
		else]]if ( isFree ) then
			card.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_FREE);
		elseif ( discount ) then
			card.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_DISCOUNT_FORMAT:format(discountAmount));
		else
			card.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_FEATURED);
		end
	end 

	card.NormalPrice:SetText(currencyFormat(normalDollars, normalCents));
	card.ProductName:SetText(name);
	
	if (card.Description) then
		card.Description:SetText(description);
	else
		card.title = name;
		card.description = description;
	end

	if ( displayID ) then
		StoreProductCard_SetModel(card, displayID, owned);
		card.name = name;
	else
		local icon = texture;
		if (not icon) then
			icon = "Interface\\Icons\\INV_Misc_Note_02";
		end	
		StoreProductCard_ShowIcon(card, icon);
	end

	if (discount) then
		StoreProductCard_ShowDiscount(card, currencyFormat(currentDollars, currentCents), discountReset);
	end

	if (card.BuyButton) then
		card.BuyButton:SetEnabled(buyableHere);
	else
		card.Card:SetDesaturated(not buyableHere);
	end

	card:SetID(entryID);
	card:Show();
end

function StoreFrame_SetSplashCategory(id)
	local self = StoreFrame;

	local info = currencyInfo();

	if ( not info ) then
		return;
	end

	self.SplashSingle:Hide();
	self.SplashPrimary:Hide();
	self.SplashSecondary1:Hide();
	self.SplashSecondary2:Hide();
	
	for i = 1, NUM_STORE_PRODUCT_CARDS do
		local card = self.ProductCards[i];
		card:Hide();
	end

	local currencyFormat = info.formatShort;
	self.Notice:Hide();
	selectedEntryID = nil;

	local products = C_PurchaseAPI.GetProducts(id);

	local isThreeSplash = #products == 3;

	if (isThreeSplash) then
		StoreFrame_UpdateCard(self.SplashPrimary, products[1]);
		StoreFrame_UpdateCard(self.SplashSecondary1, products[2]);
		StoreFrame_UpdateCard(self.SplashSecondary2, products[3]);
		self.SplashPrimary:Show();
		self.SplashSecondary1:Show();
		self.SplashSecondary2:Show();
	else
		selectedEntryID = products[1]; -- This is the only card here so just auto select it so the buy button works
		StoreFrame_UpdateCard(self.SplashSingle, products[1]);
		self.SplashSingle:Show();
	end

	StoreFrame_UpdateBuyButton();
	
	self.PageText:Hide();
	self.NextPageButton:Hide();
	self.PrevPageButton:Hide();
end

function StoreFrame_SetNormalCategory(id)
	local self = StoreFrame;
	local pageNum = selectedPageNum;
	
	local info = currencyInfo();

	if ( not info ) then
		return;
	end

	self.SplashSingle:Hide();
	self.SplashPrimary:Hide();
	self.SplashSecondary1:Hide();
	self.SplashSecondary2:Hide();

	local currencyFormat = info.formatShort;

	selectedEntryID = nil;

	local products = C_PurchaseAPI.GetProducts(id);
	local numTotal = #products;

	for i=1, NUM_STORE_PRODUCT_CARDS do
		local card = self.ProductCards[i];
		local entryID = products[i + NUM_STORE_PRODUCT_CARDS * (pageNum - 1)];
		if ( not entryID ) then
			card:Hide();
		else
			card:Show();

			StoreFrame_UpdateCard(card, entryID);
		end
	end

	if ( #products > NUM_STORE_PRODUCT_CARDS ) then
		-- 10, 10/8 = 1, 2 remain 
		local numPages = math.ceil(#products / NUM_STORE_PRODUCT_CARDS);
		self.PageText:SetText(BLIZZARD_STORE_PAGE_NUMBER:format(pageNum,numPages));
		self.PageText:Show();
		self.NextPageButton:Show();
		self.PrevPageButton:Show();
		self.PrevPageButton:SetEnabled(pageNum ~= 1);
		self.NextPageButton:SetEnabled(pageNum ~= numPages);
	else
		self.PageText:Hide();
		self.NextPageButton:Hide();
		self.PrevPageButton:Hide();
	end

	StoreFrame_UpdateBuyButton();
end

function StoreFrame_SetCategory(id)
	local _, _, _, _, categoryType = C_PurchaseAPI.GetProductGroupInfo(id);
	if (categoryType == BATTLEPAY_GROUP_DISPLAY_SPLASH) then
		StoreFrame_SetSplashCategory(id);
	else
		StoreFrame_SetNormalCategory(id);
	end
end

function StoreFrame_CreateCards(self, num, numPerRow)
	for i=1, num do
		local card = self.ProductCards[i];
		if ( not card ) then
			card = CreateForbiddenFrame("Button", nil, self, "StoreProductCardTemplate");
			
			StoreProductCard_OnLoad(card);
			self.ProductCards[i] = card;

			if ( i % numPerRow == 1 ) then
				card:SetPoint("TOP", self.ProductCards[i - numPerRow], "BOTTOM", 0, 0);
			else
				card:SetPoint("TOPLEFT", self.ProductCards[i - 1], "TOPRIGHT", 0, 0);
			end

			if ((i % 4) == 0) then
				card.tooltipSide = "LEFT";
			else
				card.tooltipSide = "RIGHT";
			end

			card:SetScript("OnEnter", StoreProductCard_OnEnter);
			card:SetScript("OnLeave", StoreProductCard_OnLeave);
			card:SetScript("OnClick", StoreProductCard_OnClick);
			card:SetScript("OnDragStart", StoreProductCard_OnDragStart);
			card:SetScript("OnDragStop", StoreProductCard_OnDragStop);
		end
	end
end

function StoreFrame_UpdateCategories(self)
	local categories = C_PurchaseAPI.GetProductGroups();
	for i=1, #categories do
		local frame = self.CategoryFrames[i];
		local groupID = categories[i];
		if ( not frame ) then
			frame = CreateForbiddenFrame("Button", nil, self, "StoreCategoryTemplate");

			frame:SetScript("OnEnter", StoreCategory_OnEnter);
			frame:SetScript("OnLeave", StoreCategory_OnLeave);
			frame:SetScript("OnClick", StoreCategory_OnClick);
			frame:SetPoint("TOPLEFT", self.CategoryFrames[i - 1], "BOTTOMLEFT", 0, 0);

			self.CategoryFrames[i] = frame;
		end

		frame:SetID(groupID);
		local _, name, _, texture = C_PurchaseAPI.GetProductGroupInfo(groupID);
		frame.Icon:SetTexture(texture);
		frame.Text:SetText(name);
		frame.SelectedTexture:SetShown(selectedCategoryId == groupID);
		frame:Show();
	end

	for i=#categories + 1, #self.CategoryFrames do
		self.CategoryFrames[i]:Hide();
	end
end

function StoreFrame_OnLoad(self)
	StoreFrame = self;	--Save off a reference for us
	self:RegisterEvent("STORE_PRODUCTS_UPDATED");
	self:RegisterEvent("STORE_PURCHASE_LIST_UPDATED");
	self:RegisterEvent("BAG_UPDATE_DELAYED"); --Used for showing the panel when all bags are full
	self:RegisterEvent("STORE_PURCHASE_ERROR");
	self:RegisterEvent("STORE_ORDER_INITIATION_FAILED");
	C_PurchaseAPI.GetPurchaseList();

	self.TitleText:SetText(BLIZZARD_STORE);
	
	SetPortraitToTexture(self.portrait, "Interface\\Icons\\WoW_Store");
	self.BuyButton:SetText(BLIZZARD_STORE_BUY);

	if ( IsOnGlueScreen() ) then
		self:SetFrameStrata("FULLSCREEN_DIALOG");
		-- block keys
		self:EnableKeyboard(true);
		self:SetScript("OnKeyDown",
			function(self, key)
				if ( key == "ESCAPE" ) then
					if ( _G.ModelPreviewFrame:IsShown() ) then
						_G.ModelPreviewFrame:Hide();
					else
						StoreFrame:SetAttribute("action", "EscapePressed");
					end
				end
			end
		);
		-- block other clicks
		local bgFrame = CreateForbiddenFrame("FRAME", nil);
		bgFrame:SetParent(self);
		bgFrame:SetAllPoints(_G.GlueParent);
		bgFrame:SetFrameStrata("DIALOG");
		bgFrame:EnableMouse(true);
		-- background texture
		local background = bgFrame:CreateTexture(nil, "BACKGROUND");
		background:SetAllPoints(_G.GlueParent);
		background:SetTexture(0, 0, 0, 0.75);
	end
	self:SetPoint("CENTER", nil, "CENTER", 0, 20); --Intentionally not anchored to UIParent.

	StoreFrame_CreateCards(self, NUM_STORE_PRODUCT_CARDS, NUM_STORE_PRODUCT_CARDS_PER_ROW);

	StoreFrame.SplashSingle:Hide();
	StoreFrame.SplashPrimary:Hide();
	StoreFrame.SplashSecondary1:Hide();
	StoreFrame.SplashSecondary2:Hide();

	StoreFrame.SplashSingle.SplashBannerText:SetShadowColor(0, 0, 0, 0);
	StoreFrame.SplashPrimary.SplashBannerText:SetShadowColor(0, 0, 0, 0);
	StoreFrame.SplashPrimary.Description:SetSpacing(5);
	StoreFrame_UpdateActivePanel(self);

	--Check whether we already have an error waiting for us.
	local errorID, internalErr = C_PurchaseAPI.GetFailureInfo();
	if ( errorID ) then
		StoreFrame_OnError(self, errorID, true, internalErr);
	end
end

function StoreFrame_OnEvent(self, event, ...)
	if ( event == "STORE_PRODUCTS_UPDATED" ) then
		if ( not selectedCategoryId ) then
			selectedCategoryId = C_PurchaseAPI.GetProductGroups()[1];
		end
		StoreFrame_UpdateCategories(self);
		StoreFrame_SetCategory(selectedCategoryId);
		StoreFrame_UpdateActivePanel(self);
	elseif ( event == "STORE_PURCHASE_LIST_UPDATED" ) then
		JustOrderedProduct = false;
		StoreFrame_UpdateCategories(self);
		StoreFrame_UpdateActivePanel(self);
	elseif ( self:IsShown() and event == "BAG_UPDATE_DELAYED" ) then
		StoreFrame_UpdateActivePanel(self);
	elseif ( event == "STORE_PURCHASE_ERROR" ) then
		local err, internalErr = C_PurchaseAPI.GetFailureInfo();
		StoreFrame_OnError(self, err, true, internalErr);
	elseif ( event == "STORE_ORDER_INITIATION_FAILED" ) then
		local err, internalErr = ...;
		WaitingOnConfirmation = false;
		StoreFrame_OnError(self, err, false, internalErr);
		StoreFrame_UpdateActivePanel(self);
	end
end

function StoreFrame_OnShow(self)
	C_PurchaseAPI.GetProductList();
	self:SetAttribute("isshown", true);
	StoreFrame_UpdateActivePanel(self);
	if ( not IsOnGlueScreen() ) then
		Outbound.UpdateMicroButtons();
	end

	StoreFrame_UpdateCoverState();
	PlaySound("UI_igStore_WindowOpen_Button");
end

function StoreFrame_UpdateBuyButton()
	local self = StoreFrame;

	if (StoreFrame.SplashSingle:IsShown()) then
		self.BuyButton:Hide();
	else
		self.BuyButton:Show();
	end

	if (not selectedEntryID) then
		self.BuyButton:SetText(BLIZZARD_STORE_BUY);
		self.BuyButton:SetEnabled(false);
		return;
	end

	local entryID = selectedEntryID;
	local currentDollars, currentCents = select(8,C_PurchaseAPI.GetEntryInfo(entryID));

	if (currentDollars == 0 and currentCents == 0) then
		self.BuyButton:SetText(BLIZZARD_STORE_CLAIM);
	else
		self.BuyButton:SetText(BLIZZARD_STORE_BUY);
	end

	self.BuyButton:SetEnabled(true);
end

function StoreFrame_UpdateCoverState()
	local self = StoreFrame;
	if (StoreConfirmationFrame and StoreConfirmationFrame:IsShown() ) then
		self.Cover:Show();
	elseif (self.Notice:IsShown()) then
		self.Cover:Show();
	elseif (self.ErrorFrame:IsShown()) then
		self.Cover:Show();
	elseif (self:GetAttribute("previewframeshown")) then
		self.Cover:Show();
	else
		self.Cover:Hide();
	end
end

function StoreFrame_OnAttributeChanged(self, name, value)
	--Note - Setting attributes is how the external UI should communicate with this frame. That way, their taint won't be spread to this code.
	if ( name == "action" ) then
		if ( value == "Show" ) then
			self:Show();
		elseif ( value == "Hide" ) then
			self:Hide();
		elseif ( value == "EscapePressed" ) then
			local handled = false;
			if ( self:IsShown() ) then
				if ( self.ErrorFrame:IsShown() or StoreConfirmationFrame:IsShown() ) then
					--We eat the click, but don't close anything. Make them explicitly press "Cancel".
					handled = true;
				else
					self:Hide();
					handled = true;
				end
			end
			self:SetAttribute("escaperesult", handled);
		end
	elseif ( name == "previewframeshown" ) then
		StoreFrame_UpdateCoverState();
	end
end

function StoreFrame_OnError(self, errorID, needsAck, internalErr)
	local info = errorData[errorID];
	if ( not info ) then
		info = errorData[LE_STORE_ERROR_OTHER];
	end
	if ( IsGMClient() ) then
		StoreFrame_ShowError(self, info.title.." ("..internalErr..")", info.msg, info.link, needsAck);
	else
		StoreFrame_ShowError(self, info.title, info.msg, info.link, needsAck);
	end
end

function StoreFrame_UpdateActivePanel(self)
	if (StoreFrame.ErrorFrame:IsShown()) then
		StoreFrame_HideAlert(self);
	elseif ( WaitingOnConfirmation ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_CONNECTING, BLIZZARD_STORE_PLEASE_WAIT);
	elseif ( JustOrderedProduct ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_TRANSACTION_IN_PROGRESS, BLIZZARD_STORE_CHECK_BACK_LATER);
	elseif ( C_PurchaseAPI.HasPurchaseInProgress() ) then --Even if we don't have every list, if we know we have something in progress, we can display that.
		StoreFrame_SetAlert(self, BLIZZARD_STORE_TRANSACTION_IN_PROGRESS, BLIZZARD_STORE_CHECK_BACK_LATER);
	elseif ( not C_PurchaseAPI.IsAvailable() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_NOT_AVAILABLE, BLIZZARD_STORE_NOT_AVAILABLE_SUBTEXT);
	elseif ( C_PurchaseAPI.IsRegionLocked() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_REGION_LOCKED, BLIZZARD_STORE_REGION_LOCKED_SUBTEXT);
	elseif ( not C_PurchaseAPI.HasPurchaseList() or not C_PurchaseAPI.HasProductList() or not C_PurchaseAPI.HasDistributionList() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_LOADING, BLIZZARD_STORE_PLEASE_WAIT);
	elseif ( #C_PurchaseAPI.GetProductGroups() == 0 ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_NO_ITEMS, BLIZZARD_STORE_CHECK_BACK_LATER);
	elseif ( not IsOnGlueScreen() and not StoreFrame_HasFreeBagSlots() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_BAG_FULL, BLIZZARD_STORE_BAG_FULL_DESC);
	elseif ( not currencyInfo() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_INTERNAL_ERROR, BLIZZARD_STORE_INTERNAL_ERROR_SUBTEXT);
	else
		StoreFrame_HideAlert(self);
		local info = currencyInfo();
		self.BrowseNotice:SetText(info.browseNotice);
	end
end

function StoreFrame_SetAlert(self, title, desc)
	self.Notice.Title:SetText(title);
	self.Notice.Description:SetText(desc);
	self.Cover:Show();
	self.Notice:Show();

	if ( StoreConfirmationFrame ) then
		StoreConfirmationFrame:Raise(); --Make sure the confirmation is above this alert frame.
	end
end

function StoreFrame_HideAlert(self)
	self.Notice:Hide();
end

local ActiveURLIndex = nil;
local ErrorNeedsAck = nil;
function StoreFrame_ShowError(self, title, desc, urlIndex, needsAck)
	local height = 160;
	self.ErrorFrame.Title:SetText(title);
	self.ErrorFrame.Description:SetText(desc);
	self.ErrorFrame.AcceptButton:SetText(OKAY);
	height = height + self.ErrorFrame.Description:GetHeight() + self.ErrorFrame.Title:GetHeight();

	if ( urlIndex ) then
		self.ErrorFrame.AcceptButton:ClearAllPoints();
		self.ErrorFrame.AcceptButton:SetPoint("BOTTOMRIGHT", self.ErrorFrame, "BOTTOM", -10, 20);
		self.ErrorFrame.WebsiteButton:ClearAllPoints();
		self.ErrorFrame.WebsiteButton:SetPoint("BOTTOMLEFT", self.ErrorFrame, "BOTTOM", 10, 20);
		self.ErrorFrame.WebsiteButton:Show();
		self.ErrorFrame.WebsiteButton:SetText(BLIZZARD_STORE_VISIT_WEBSITE);
		self.ErrorFrame.WebsiteWarning:Show();
		self.ErrorFrame.WebsiteWarning:SetText(BLIZZARD_STORE_VISIT_WEBSITE_WARNING);
		height = height + self.ErrorFrame.WebsiteWarning:GetHeight() + 5;
		ActiveURLIndex = urlIndex;
	else
		self.ErrorFrame.AcceptButton:ClearAllPoints();
		self.ErrorFrame.AcceptButton:SetPoint("BOTTOM", self.ErrorFrame, "BOTTOM", 0, 20);
		self.ErrorFrame.WebsiteButton:Hide();
		self.ErrorFrame.WebsiteWarning:Hide();
		ActiveURLIndex = nil;
	end
	ErrorNeedsAck = needsAck;

	self.Cover:Show();
	self.ErrorFrame:Show();
	self.ErrorFrame:SetHeight(height);

	if ( StoreConfirmationFrame ) then
		StoreConfirmationFrame:Raise(); --Make sure the confirmation is above this error frame.
	end
end

function StoreFrameErrorFrame_OnShow(self)
	StoreFrame_UpdateActivePanel(StoreFrame);
	StoreFrame_UpdateCoverState();
	self:SetFrameLevel(self:GetParent():GetFrameLevel()+4);
end

function StoreFrameErrorFrame_OnHide(self)
	StoreFrame_UpdateCoverState();
	StoreFrame_UpdateActivePanel(StoreFrame);
end

function StoreFrameErrorAcceptButton_OnClick(self)
	if ( ErrorNeedsAck ) then
		C_PurchaseAPI.AckFailure();
	end
	StoreFrame.ErrorFrame:Hide();
end

function StoreFrameErrorWebsiteButton_OnClick(self)
	LoadURLIndex(ActiveURLIndex);
end

function StoreFrameCloseButton_OnClick(self)
	StoreFrame:Hide();
end

function StoreFrameBuyButton_OnClick(self)
	local entryID = selectedEntryID
	StoreFrame_BeginPurchase(entryID);
	StoreConfirmationFrame_Update(StoreConfirmationFrame);
	PlaySound("UI_igStore_Buy_Button");
end

function StoreFrame_BeginPurchase(entryID)
	WaitingOnConfirmation = true;
	local productID = C_PurchaseAPI.GetEntryInfo(entryID);
	StoreFrame_UpdateActivePanel(StoreFrame);
	C_PurchaseAPI.PurchaseProduct(productID);
end

function StoreFrame_HasFreeBagSlots()
	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local freeSlots, bagFamily = GetContainerNumFreeSlots(i);
		if ( freeSlots > 0 and bagFamily == 0 ) then
			return true;
		end
	end
	return false;
end

function StoreFramePrevPageButton_OnClick(self)
	selectedPageNum = selectedPageNum - 1;
	StoreFrame_SetCategory(selectedCategoryId);

	PlaySound("UI_igStore_PageNav_Button");
end

function StoreFrameNextPageButton_OnClick(self)
	selectedPageNum = selectedPageNum + 1;
	StoreFrame_SetCategory(selectedCategoryId);

	PlaySound("UI_igStore_PageNav_Button");
end

local ConfirmationFrameHeight = 556;
local ConfirmationFrameMiddleHeight = 200;

------------------------------------------
function StoreConfirmationFrame_OnLoad(self)
	StoreConfirmationFrame = self;

	self.ProductName:SetTextColor(0.3, 0.3, 0.3);
	
	self.Title:SetText(BLIZZARD_STORE_CONFIRMATION_TITLE);

	self.BuyButton:SetText(BLIZZARD_STORE_FINAL_BUY);

	self.LicenseAcceptText:SetTextColor(0.8, 0.8, 0.8);

	self.NoticeFrame.Notice:SetSpacing(6);

	self:RegisterEvent("STORE_CONFIRM_PURCHASE");
end

function StoreConfirmationFrame_SetNotice(self, icon, name, dollars, cents)
	self:SetHeight(ConfirmationFrameHeight);
	self.ParchmentMiddle:SetHeight(ConfirmationFrameMiddleHeight);
	SetPortraitToTexture(self.Icon, icon);

	self.ProductName:SetText(name);
	self.NoticeFrame.Notice:ClearAllPoints();
	self.NoticeFrame.Notice:SetPoint("TOP", 0, 100);
	local info = currencyInfo();
	local format = info.formatLong;
	self.NoticeFrame.Notice:SetText(info.confirmationNotice);
	self.NoticeFrame:Show();
	self.Price:SetText(format(dollars, cents))
	self:ClearAllPoints();
	self:SetPoint("CENTER", 0, 0);
end

function StoreConfirmationFrame_OnEvent(self, event, ...)
	if ( event == "STORE_CONFIRM_PURCHASE" ) then
		WaitingOnConfirmation = false;
		StoreFrame_UpdateActivePanel(StoreFrame);
		if ( StoreFrame:IsShown() ) then
			StoreConfirmationFrame_Update(self);
			self:Raise();
		else
			C_PurchaseAPI.PurchaseProductConfirm(false);
		end
	end
end

function StoreConfirmationFrame_OnShow(self)
	StoreFrame_UpdateCoverState();
	self:Raise();
end

function StoreConfirmationFrame_OnHide(self)
	if (not JustOrderedProduct) then
		StoreConfirmationFrame_Cancel();
	end
	StoreFrame_UpdateCoverState();
end

local FinalPriceDollars;
local FinalPriceCents;
function StoreConfirmationFrame_Update(self)
	local productID = C_PurchaseAPI.GetConfirmationInfo();
	if ( not productID ) then
		self:Hide(); --May want to show an error message
		return;
	end
	local _, _, _, _, _, currentDollars, currentCents, _, name, _, displayID, texture = C_PurchaseAPI.GetProductInfo(productID);

	local finalIcon = texture;
	if ( not finalIcon ) then
		finalIcon = "Interface\\Icons\\INV_Misc_Note_02";
	end
	StoreConfirmationFrame_SetNotice(self, finalIcon, name, currentDollars, currentCents);

	local info = currencyInfo();
	if ( info.licenseAcceptText and info.licenseAcceptText ~= "" ) then
		self.LicenseAcceptText:SetText(info.licenseAcceptText, true);
		self.LicenseAcceptText:Show();
		if ( info.requireLicenseAccept ) then
			self.LicenseAcceptText:SetPoint("BOTTOM", 20, 70);
			self.LicenseAcceptButton:Show();
			self.LicenseAcceptButton:SetChecked(false);
			self.BuyButton:Disable();
		else
			self.LicenseAcceptText:SetPoint("BOTTOM", 0, 70);
			self.LicenseAcceptButton:Hide();
			self.BuyButton:Enable();
		end
	else
		self.LicenseAcceptText:Hide();
		self.LicenseAcceptButton:Hide();
		self.BuyButton:Enable();
	end
	FinalPriceDollars = currentDollars;
	FinalPriceCents = currentCents;

	self:Show();
end

function StoreConfirmationFrame_Cancel(self)
	C_PurchaseAPI.PurchaseProductConfirm(false);
	StoreConfirmationFrame:Hide();

	PlaySound("UI_igStore_Cancel_Button");
end

function StoreConfirmationFinalBuy_OnClick(self)
	if ( C_PurchaseAPI.PurchaseProductConfirm(true, FinalPriceDollars, FinalPriceCents) ) then
		JustOrderedProduct = true;
		PlaySound("UI_igStore_ConfirmPurchase_Button");
	else
		StoreFrame_OnError(StoreFrame, LE_STORE_ERROR_OTHER, false, "Fake");
		PlaySound("UI_igStore_Cancel_Button");
	end
	StoreFrame_UpdateActivePanel(StoreFrame);
	StoreConfirmationFrame:Hide();
end

-------------------------------
local isRotating = false;

function StoreProductCard_Update(card)
	if (card.HighlightTexture) then
		local enableHighlight = card:GetID() ~= selectedEntryID and not isRotating;
		card.HighlightTexture:SetAlpha(enableHighlight and 1 or 0);
	end
	if (card.Magnifier) then
		local enableMagnifier = not isRotating;
		card.Magnifier:SetAlpha(enableMagnifier and 1 or 0);
	end
end

function StoreProductCard_UpdateAllCards()
	for i = 1, NUM_STORE_PRODUCT_CARDS do
		local card = StoreFrame.ProductCards[i];
		StoreProductCard_Update(card);
	end
end

function StoreProductCard_OnEnter(self)
	self.HighlightTexture:SetShown(selectedEntryID ~= self:GetID());
	if (self.Magnifier and self.Model:IsShown()) then
		self.Magnifier:Show();
	end
	if (self.description and not self.Description) then
		local point, rpoint, xoffset;
		if (self.tooltipSide == "LEFT") then
			point = "TOPRIGHT";
			rpoint = "TOPLEFT";
			xoffset = -4;
		else
			point = "TOPLEFT";
			rpoint ="TOPRIGHT";
			xoffset = 4;
		end
		StoreTooltip_SetInfo(self.title, self.description);
		StoreTooltip:ClearAllPoints();
		StoreTooltip:SetPoint(point, self, rpoint, xoffset, 0);
		StoreTooltip:Show();
	end
	StoreProductCard_Update(self);
end

function StoreProductCard_OnLeave(self)
	self.HighlightTexture:Hide();
	if (self.Magnifier) then
		self.Magnifier:Hide();
	end
	StoreTooltip:Hide();
end

local function updateSelected(self, card)
	card.SelectedTexture:SetShown(card:GetID() == self:GetID());
end

function StoreProductSplashCard_OnClick(self,button,down)
	updateSelected(self, StoreFrame.SplashPrimary);
	updateSelected(self, StoreFrame.SplashSecondary1);
	updateSelected(self, StoreFrame.SplashSecondary2);

	selectedEntryID = self:GetID();
	StoreFrame_UpdateBuyButton();
	self.HighlightTexture:Hide();
end

function StoreProductCard_OnClick(self,button,down)
	for i=1,NUM_STORE_PRODUCT_CARDS do
		local card = StoreFrame.ProductCards[i];
		card.SelectedTexture:SetShown(card:GetID() == self:GetID());
	end
	selectedEntryID = self:GetID();

	StoreFrame_UpdateBuyButton();
	self.HighlightTexture:Hide();
end

function StoreProductCard_OnLoad(self)
	-- set up data
	self.Model.maxZoom = 0.7;
	self.Model.minZoom = 0.0;
	self.Model.defaultRotation = 0.61;
	
	self.Model.rotation = self.Model.defaultRotation;
	self.Model:SetRotation(self.Model.rotation);
	self.Model:RegisterEvent("UI_SCALE_CHANGED");
	self.Model:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self.Model:SetScript("OnEvent", StoreProductCard_ModelOnEvent);

	self.ProductName:SetSpacing(3);

	self.NormalPrice.basePoint = { self.NormalPrice:GetPoint() };

	self:RegisterForDrag("LeftButton");
end

function StoreProductCardModel_RotateLeft(model, rotationIncrement)
	if ( not rotationIncrement ) then
		rotationIncrement = 0.03;
	end
	model.rotation = model.rotation - rotationIncrement;
	model:SetRotation(model.rotation);
	PlaySound("igInventoryRotateCharacter");
end

function StoreProductCardModel_RotateRight(model, rotationIncrement)
	if ( not rotationIncrement ) then
		rotationIncrement = 0.03;
	end
	model.rotation = model.rotation + rotationIncrement;
	model:SetRotation(model.rotation);
	PlaySound("igInventoryRotateCharacter");
end

function StoreProductCardModel_OnMouseDown(model, button)
	if ( button == "LeftButton" ) then
		model.mouseDown = true;
		model.rotationCursorStart = GetCursorPosition();
		local card = model:GetParent();
		isRotating = true;
		StoreProductCard_Update(card);
	end
end

function StoreProductCardModel_OnMouseUp(model, button)
	if ( button == "LeftButton" ) then
		model.mouseDown = false;
		local card = model:GetParent();
		isRotating = false;
		StoreProductCard_UpdateAllCards();
	end
end

function StoreProductCardModel_OnUpdate(self, elapsedTime, rotationsPerSecond)
	if ( not rotationsPerSecond ) then
		rotationsPerSecond = ROTATIONS_PER_SECOND;
	end
	
	-- Mouse drag rotation
	if (self.mouseDown) then
		if ( self.rotationCursorStart ) then
			local x = GetCursorPosition();
			local diff = (x - self.rotationCursorStart) * MODELFRAME_DRAG_ROTATION_CONSTANT;
			self.rotationCursorStart = GetCursorPosition();
			self.rotation = self.rotation + diff;
			if ( self.rotation < 0 ) then
				self.rotation = self.rotation + (2 * PI);
			end
			if ( self.rotation > (2 * PI) ) then
				self.rotation = self.rotation - (2 * PI);
			end
			self:SetRotation(self.rotation, false);
		end	
	end
end

function StoreProductCard_OnDragStart(self)
	StoreProductCardModel_OnMouseDown(self.Model, "LeftButton");
end

function StoreProductCard_OnDragStop(self)
	StoreProductCardModel_OnMouseUp(self.Model, "LeftButton");
end

function StoreProductCard_ResetModel(self)
	self.Model.rotation = self.Model.defaultRotation;
	self.Model:SetRotation(self.Model.rotation);
	self.Model:SetPosition(0, 0, 0);
	self.Model.zoomLevel = self.Model.minZoom;
	self.Model:SetPortraitZoom(self.Model.zoomLevel);
end

function StoreProductCard_ModelOnEvent(self, event, ...)
	self:RefreshCamera();
end

function StoreProductCard_SetModel(self, modelID, owned)
	self.Model:Show();
	self.Shadows:Show();
	self.Model:SetDisplayInfo(modelID);
	self.Model:SetDoBlend(false);
	self.Model:SetAnimation(0,-1);
	self.modelID = modelID;
	if ( owned ) then
		self.Checkmark:Show();
	end
end

function StoreProductCard_ShowIcon(self, icon)
	self.IconBorder:Show();
	self.Icon:Show();

	SetPortraitToTexture(self.Icon, icon);
end

function StoreProductCard_ShowDiscount(card, discountText)
	card.SalePrice:SetText(discountText);


	if (card.Magnifier) then -- Magnifier is our "normal" card marker, the splash cards don't need this
		local width = card.NormalPrice:GetStringWidth() + card.SalePrice:GetStringWidth();
		
		if ((width + 20 + (card:GetWidth()/8)) > card:GetWidth()) then
			card.NormalPrice:ClearAllPoints();
			card.NormalPrice:SetPoint(unpack(card.NormalPrice.basePoint));
			card.SalePrice:ClearAllPoints();
			card.SalePrice:SetPoint("TOP", card.NormalPrice, "BOTTOM", 0, -4);
		else
			local diff = card.NormalPrice:GetStringWidth() - card.SalePrice:GetStringWidth();
			local _, _, _, _, yOffset = unpack(card.NormalPrice.basePoint);
			card.NormalPrice:ClearAllPoints();
			card.NormalPrice:SetJustifyH("RIGHT");
			card.NormalPrice:SetPoint("BOTTOMRIGHT", card, "BOTTOM", diff/2, yOffset);
			card.SalePrice:ClearAllPoints();
			card.SalePrice:SetJustifyH("LEFT");
			card.SalePrice:SetPoint("BOTTOMLEFT", card.NormalPrice, "BOTTOMRIGHT", 3, 0);
		end
	end
		
	card.CurrentPrice:Hide();
	card.NormalPrice:Show();
	card.SalePrice:Show();

	card.Strikethrough:Show();
end

function StoreProductCardMagnifyingGlass_OnEnter(self)
	StoreProductCard_OnEnter(self:GetParent());
end

function StoreProductCardMagnifyingGlass_OnLeave(self)
	StoreProductCard_OnLeave(self:GetParent());
end

function StoreProductCardMagnifyingGlass_OnClick(self, button, down)
	 local card = self:GetParent();
	 local name = card.name;
	 local modelID = card.modelID;
	 StoreFrame.Cover:Show();
	 Outbound.ShowPreview(name, modelID);
end

function StoreProductCard_ResetCard(card)
	if (card.NewTexture) then
		card.NewTexture:Hide();
	end

	if (card.HotTexture) then
		card.HotTexture:Hide();
	end

	if (card.DiscountTexture) then
		card.DiscountTexture:Hide();
		card.DiscountLeft:Hide();
		card.DiscountRight:Hide();
		card.DiscountText:Hide();
	end

	if (card.Checkmark) then
		card.Checkmark:Hide();
	end

	card.Model:Hide();
	card.Shadows:Hide();
	card.IconBorder:Hide();
	card.Icon:Hide();

	if (card.Magnifier) then
		card.Magnifier:Hide();
	end

	if (card.SelectedTexture) then
		card.SelectedTexture:Hide();
	end

	card.CurrentPrice:Show();
	card.NormalPrice:Hide();
	card.SalePrice:Hide();
	card.Strikethrough:Hide();
	
	StoreProductCard_ResetModel(card);
end

------------------------------
function StoreCategory_OnEnter(self)
	self.HighlightTexture:Show();
end

function StoreCategory_OnLeave(self)
	self.HighlightTexture:Hide();
end

function StoreCategory_OnClick(self,button,down)
	selectedCategoryId = self:GetID();
	StoreFrame_UpdateCategories(StoreFrame);

	selectedPageNum = 1;
	StoreFrame_SetCategory(self:GetID());

	for i = 1, NUM_STORE_PRODUCT_CARDS do
		local card = StoreFrame.ProductCards[i];
		card.SelectedTexture:Hide();
	end
end

----------------------------------
function StoreTooltip_OnLoad(self)
	StoreTooltip = self;
	self:SetBackdropColor(0, 0, 0, 1)
end

function StoreTooltip_OnShow(self)
	-- 10 pixel buffer between top, 10 between name and description, 10 between description and bottom
	local nheight, dheight = self.ProductName:GetHeight(), self.Description:GetHeight();
	local buffer = 10;

	self:SetHeight(buffer*3 + nheight + dheight);
	self:SetFrameLevel(self:GetParent():GetFrameLevel()+3);
end

function StoreTooltip_SetInfo(name, description)
	StoreTooltip.ProductName:SetText(name);
	StoreTooltip.Description:SetText(description);
end

----------------------------------
function StoreButton_OnShow(self)
	if ( self:IsEnabled() ) then
		-- we need to reset our textures just in case we were hidden before a mouse up fired
		self.Left:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
		self.Middle:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
		self.Right:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
	end
	local textWidth = self.Text:GetWidth();
	local width = self:GetWidth();
	if ( (width - 40) < textWidth ) then
		self:SetWidth(textWidth + 40);
	end
end
