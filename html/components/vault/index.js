import importTemplate from "../../util/importTemplate.js";
import inlinesvg from "../../util/inlineSvg.js";
import playerinformation from "../playerinformation/index.js";
export default {
    template: await importTemplate("components/vault/index.html"),
    data: () => ({
        hasPermission: true,
        companyAmount: 0,
        moneyloginput: "",
        oldData: false,
        selectedIdentifier : false,

    }),
    methods: {
        ToggleAction(){
            postNUI("ToggleVaultAccess")  
        },
        filternotificationdataAll() {
            this.$store.dispatch("filternotificationdataAll", this.oldData);
            this.selectedIdentifier = false

        },
        filternotificationdata(identifier) {
            this.$store.dispatch("filternotificationdata", { identifier, oldData: this.oldData });
            this.selectedIdentifier = identifier

        },
        depositMoney() {
            if (this.companyAmount > 0) {
                postNUI("depositMoney", { amount: this.companyAmount });
            }
        },
        withdrawMoney() {
            if (this.companyAmount > 0) {
                postNUI("withdrawMoney", { amount: this.companyAmount });
            }
        },
        checkInput() {
            if (this.companyAmount.length > 0) {
                this.companyAmount = this.companyAmount.replace(/[^0-9]/g, "");
            }
        }
    },
    computed: {
        ...Vuex.mapState({
            playerInfo: state => state.playerInfo,
            jobInfo: state => state.jobInfo,
            vaultData: state => state.vaultData,
            companyData: state => state.companyData,
            vaultDataHistory: state => state.vaultDataHistory,
            locales : state => state.locales,

        }),
 
        formattedJob() {
            return this.jobInfo.label + "-" + this.jobInfo.grade_label;
        },
        getCardBG(){
            if(this.companyData.theme == 'blue'){
                return `./assets/images/card-container.png`
            } else{
                return `./assets/images/${this.companyData.theme}/card-container.png`

            }

        },
        filterByTermTransactionData() {
            if (this.moneyloginput.length > 0) {
                if (!this.vaultDataHistory || this.vaultDataHistory.length <= 0) {
                    return this.vaultDataHistory;
                }
                return this.vaultDataHistory.filter(name => {
                    return (
                        String(name.to).toLowerCase().includes(this.moneyloginput.toLowerCase()) ||
                        String(name.from).toLowerCase().includes(this.moneyloginput.toLowerCase()) ||
                        String(name.label).toLowerCase().includes(this.moneyloginput.toLowerCase()) ||
                        String(name.type).toLowerCase().includes(this.moneyloginput.toLowerCase()) ||
                        String(name.date).toLowerCase().includes(this.moneyloginput.toLowerCase()) ||
                        String(name.amount).toLowerCase().includes(this.moneyloginput.toLowerCase())
                    );
                });
            } else {
                return this.vaultDataHistory;
            }
        },
        reversedTransaction() {
            if (this.vaultDataHistory.length > 0) {
                return this.filterByTermTransactionData.slice().reverse();
            } else {
                this.vaultDataHistory;
            }
        }
    },
    watch: {},
    props: ["setCurrentAction", "currentAction", "setActivePage"],
    mounted() {
        const swiper = new Swiper(".swiper", {
            // Optional parameters
            slidesPerView: 10
        });
        this.oldData = this.vaultDataHistory;
    },
    components: {
        playerinformation,
        inlinesvg
    }
};
