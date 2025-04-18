import importTemplate from "../../util/importTemplate.js";
import inlinesvg from "../../util/inlineSvg.js";
import playerinformation from "../playerinformation/index.js";
export default {
    template: await importTemplate("components/inventory/index.html"),
    data: () => ({
        inventoryCount: 1,
        searchInventory: ""
    }),
    methods: {
        ToggleAction(){
            postNUI("ToggleInventoryAccess")  
        },
        findFirstEmptySlot(inventory) {
            for (let i = 1; i <= Object.keys(inventory).length; i++) {
                if (!inventory[i]) {
                    return i;
                }
            }
            return Object.keys(inventory).length + 1;
        },
        checkInput() {
            if (!this.inventoryCount.match(/^[1-9][0-9]*$/)) {
                this.inventoryCount = "1";
            }
        },
        mainInventoryDrop() {
            $(".companyInventoryDrop").droppable({
                tolerance: "pointer",
                drop: (event, ui) => {
                    if ($(ui.draggable).data("fromOtherInventory")) {
                        return;
                    }
                    this.handleDrop(event, ui);
                }
            });
            $(".mainInventoryDrop").droppable({
                tolerance: "pointer",
                drop: (event, ui) => {
                    if ($(ui.draggable).data("fromMainInventory")) {
                        return;
                    }
                    this.handleDropMain(event, ui);
                }
            });
        },
        async handleDropMain(event, ui) {
            const itemName = $(ui.draggable).attr("data-name");
            const itemLabel = $(ui.draggable).attr("data-label");
            let itemAmount = parseInt($(ui.draggable).attr("data-amount"), 10);
            const itemSlot = $(ui.draggable).attr("data-slot");
            if (itemAmount < this.inventoryCount) {
                console.log("item amount yeterli değil");
                return;
            }
            if (this.inventoryCount && this.inventoryCount <= 0) {
                console.log("Amount kısmı boş");
                return;
            }
            if (this.inventoryCount > 0 && this.inventoryCount <= itemAmount) {
                itemAmount = Number(this.inventoryCount);
            }
            if (itemName === undefined) {
                event.preventDefault();
                return;
            }
            try {
                const itemMetadata = this.companyInventory[itemSlot].metadata[0] || this.companyInventory[itemSlot].metadata;
                let response = await postNUI("inventoryCompanyItemCheck", {
                    itemname: itemName,
                    label: itemLabel,
                    itemamount: itemAmount,
                    metadata: itemMetadata
                });
                if (response === false) {
                    console.log("YETERLİ ITEM YOK 22");
                    return;
                }
                let existingItemKey = Object.keys(this.playerInventory).find(key => this.playerInventory[key].name === itemName);
                if (existingItemKey) {
                    this.playerInventory[existingItemKey].amount += itemAmount; // Öğe zaten varsa miktarını güncelle
                } else {
                    let emptySlot = this.findFirstEmptySlot(this.playerInventory);
                    this.playerInventory[emptySlot] = {
                        name: itemName,
                        label: itemLabel,
                        amount: itemAmount,
                        metadata: itemMetadata
                    };
                }
                this.companyInventory[itemSlot].amount -= itemAmount;
                if (this.companyInventory[itemSlot].amount <= 0) {
                    delete this.companyInventory[itemSlot];
                }
            } catch (error) {
                console.error("ERROR:", error);
            }
        },

        async handleDrop(event, ui) {
            const itemName = $(ui.draggable).attr("data-name");
            const itemLabel = $(ui.draggable).attr("data-label");
            let itemAmount = parseInt($(ui.draggable).attr("data-amount"), 10);
            const itemSlot = $(ui.draggable).attr("data-slot");
            if (itemAmount < this.inventoryCount) {
                console.log("item amount yeterli değil");
                return;
            }
            if (this.inventoryCount && this.inventoryCount <= 0) {
                console.log("Amount kısmı boş");
                return;
            }

            if (this.inventoryCount > 0 && this.inventoryCount <= itemAmount) {
                itemAmount = Number(this.inventoryCount);
            }

            if (itemName === undefined) {
                event.preventDefault();
                return;
            }

            try {
                const itemMetadata = this.playerInventory[itemSlot].metadata[0] || this.playerInventory[itemSlot].metadata;
                let response = await postNUI("inventoryItemCheck", {
                    itemname: itemName,
                    label: itemLabel,
                    itemamount: itemAmount,
                    metadata: itemMetadata
                });
                if (response === false) {
                    console.log("YETERLİ ITEM YOK");
                    return;
                }
                let existingItemKey = Object.keys(this.companyInventory).find(key => this.companyInventory[key].name === itemName);
                if (existingItemKey) {
                    this.companyInventory[existingItemKey].amount += itemAmount;
                } else {
                    let lastIndex = Object.keys(this.companyInventory).reduce((max, key) => Math.max(max, parseInt(key, 10)), 0);
                    const nextIndex = String(lastIndex + 1);

                    this.companyInventory[nextIndex] = {
                        name: itemName,
                        label: itemLabel,
                        amount: itemAmount,
                        metadata: itemMetadata
                    };
                }

                this.playerInventory[itemSlot].amount -= itemAmount;
                if (this.playerInventory[itemSlot].amount <= 0) {
                    delete this.playerInventory[itemSlot];
                }
            } catch (error) {
                console.error("ERROR:", error);
            }
        },
        mainInventoryDrag() {
            $(".mainInventorySlot").draggable({
                helper: "clone",
                revertDuration: 0,
                revert: false,
                cancel: ".item-nodrag",
                containment: "",
                scroll: false,
                start: function (event, ui) {
                    $(this).data("fromMainInventory", true);
                    ui.helper.css("width", "6.5%");
                    ui.helper.css("height", "11%");
                    ui.helper.css("opacity", "0.0");
                    ui.helper.css("z-index", "10");

                    ui.helper.animate(
                        {
                            opacity: 1.0
                        },
                        250
                    );
                },
                drag: function (event, ui) {},
                stop: (event, ui) => {
                    this.mainInventoryDrag();
                    this.mainInventoryDrop();
                }
            });
            $(".companyInventorySlot").draggable({
                helper: "clone",
                revertDuration: 0,
                revert: true,
                cancel: ".item-nodrag",
                containment: "",
                scroll: true,
                start: function (event, ui) {
                    if ($(this).children().length === 0) {
                        event.preventDefault();
                        return;
                    }
                    $(this).data("fromOtherInventory", true);
                    ui.helper.css("width", "6.5%");
                    ui.helper.css("height", "11%");
                    ui.helper.css("opacity", "0.0");
                    ui.helper.css("z-index", "10");

                    ui.helper.animate(
                        {
                            opacity: 1.0
                        },
                        250
                    );
                },
                drag: function (event, ui) {},
                stop: (event, ui) => {
                    this.mainInventoryDrag();
                    this.mainInventoryDrop();
                }
            });
        }
    },

    computed: {
        ...Vuex.mapState({
            playerInfo: state => state.playerInfo,
            jobInfo: state => state.jobInfo,
            playerInventory: state => state.playerInventory,
            setItemImagesFolder: state => state.itemImagesFolder,
            companyInventory: state => state.companyInventory,
            companyData : state => state.companyData,
            locales : state => state.locales,

        }),
        formattedJob() {
            return this.jobInfo.label + "-" + this.jobInfo.grade_label;
        },
        filterByTermInventoryData() {
            if (this.searchHistory.length > 0) {
                if (!this.playerAccount.allData.craftinghistorydata || this.playerAccount.allData.craftinghistorydata.length <= 0) {
                    return this.playerAccount.allData.craftinghistorydata;
                }
                return this.playerAccount.allData.craftinghistorydata.filter(name => {
                    return (
                        String(name.name).toLowerCase().includes(this.searchHistory.toLowerCase()) ||
                        String(name.label).toLowerCase().includes(this.searchHistory.toLowerCase()) ||
                        String(name.time).toLowerCase().includes(this.searchHistory.toLowerCase()) ||
                        String(name.result).toLowerCase().includes(this.searchHistory.toLowerCase())
                    );
                });
            } else {
                return this.playerAccount.allData.craftinghistorydata;
            }
        }
    },
    watch: {
        playerInventory(newVal, oldVal) {
            if (newVal) {
                this.playerInventory(formatInventoryData(newVal));
            }
        }
    },
    props: ["setCurrentAction", "currentAction", "setActivePage"],
    mounted() {
        setTimeout(() => {
            this.mainInventoryDrag();
            this.mainInventoryDrop();
        }, 1000);
    },
    components: {
        playerinformation,
        inlinesvg
    }
};
