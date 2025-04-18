import inlinesvg from "./util/inlineSvg.js";
import employees from "./components/employees/index.js";
import employeedetails from "./components/employeedetails/index.js";
import inventory from "./components/inventory/index.js";
import ranks from "./components/ranks/index.js";
import rankdetails from "./components/rankdetails/index.js";
import vault from "./components/vault/index.js";

import logs from "./components/logs/index.js";
import overall from "./components/overall/index.js";
import outfit from "./components/outfit/index.js";
import adminlist from "./components/adminlist/index.js";
import createmenu from "./components/createmenu/index.js";
import jobdetails from "./components/jobdetails/index.js";


const Modules = {};

const store = Vuex.createStore({
    state: {
        notifications: [],
        permissions : {},
        companies : [],
        itemImagesFolder: "",
        companyData: {},
        playerInfo: {
            name: false,
            pp: false
        },
        jobInfo: {
            name: false,
            label: false,
            level: false,
            grade_label: false
        },
        selectedRank: false,
        playerInventory: false,
        companyInventory: false,
        selectedEmployeeIdentifier: false,
        certifications: [],
        ranks: [],
        vaultData: {},
        vaultDataHistory: [],
        adminSelectedBusinessName: false,
        locales : {},
        
    },
    getters: {
        getSelectedEmployee(state) {
            return state.companyData.employees.find(employee => employee.identifier == state.selectedEmployeeIdentifier);
        },
        getAdminSelectedCompany(state) {
            return state.companies.find(company => company.company == state.adminSelectedBusinessName);
        }
    },
    actions: {
        filternotificationdataAll({ commit }, oldData) {
            commit("resetVaultDataHistory", oldData);

        },
        filternotificationdata({ commit }, { identifier, oldData }) {
            let filteredData = oldData.filter(item => item.identifier == identifier);
            commit("setVaultDataHistory", filteredData);
        }
    },
    mutations: {
        setLocales(state, payload){
            state.locales = payload
        },
        setVaultDataHistory(state, payload){
            state.vaultDataHistory = payload
        },
        resetVaultDataHistory(state, payload){
            state.vaultDataHistory = payload
        },
        setPermissions(state, payload){
            state.permissions = payload
        },
        setCompanies(state, payload){
            state.companies = payload
        },
        setAdminSelectedBusinessName(state, payload){
            state.adminSelectedBusinessName = payload
        },
        SendNotification(state, text) {
            const time = 3000;
            let id = Date.now();
            if (state.notifications.length > 0) {
                if (state.timeout) {
                    clearTimeout(state.timeout);
                    state.timeout = false;
                }
                state.notifications = [];
            }
            state.notifications.push({
                id: id,
                text: text,
                time: time
            });
            state.timeout = setTimeout(() => {
                state.notifications = state.notifications.filter(notification => notification.id != id);
            }, time);
        },
        setRanks(state, payload) {
            state.ranks = payload;
            state.ranks.sort((a, b) => b.grade - a.grade);
        },
        setCompanyMoneyData(state, payload) {
            state.vaultData = payload;
        },
        appendToCompanyMoneyLog(state, payload) {
            state.vaultDataHistory.push(payload);
        },
        resetCompanyMoneyLog(state, payload) {
            state.vaultDataHistory = payload;
        },
        setCertifications(state, payload) {
            state.certifications = payload;
        },
        setSelectedRank(state, payload) {
            state.selectedRank = payload;
        },
        setSelectedEmployeeIdentifier(state, payload) {
            state.selectedEmployeeIdentifier = payload;
        },
        setPlayerInfo(state, payload) {
            state.playerInfo[payload.type] = payload.value;
        },
        setCompanyData(state, payload) {
            state.companyData = payload;
        },
        setItemImagesFolder(state, payload) {
            state.itemImagesFolder = payload;
        },
        setJobInfo(state, payload) {
            state.jobInfo = payload;
        },
        setPlayerInventory(state, payload) {
            state.playerInventory = payload;
        },
        setPlayerCompanyInventory(state, payload) {
            state.companyInventory = payload;
        }
    },
    modules: Modules
});

const app = Vue.createApp({
    components: {
        vault: vault
    },
    data: () => ({
        activeMenu: "",
        activePage: "",
        currentAction: false,
        minute: 0,
        hour: 0,
        month: 0,
        day: 0,
        adminActivePage: ""
    }),
    computed: {
        bg(){        
            if(this.companyData.theme == 'blue'){
                return './assets/images/container-overlay.png'
            }else{
                return `./assets/images/${this.companyData.theme}/container-overlay.png`
            }
        },
        formatTime() {
            return `${this.day} ${this.month} ${this.hour}:${this.minute}`;
        },
        ...Vuex.mapState({
            companyData: state => state.companyData,
            companyInventory: state => state.companyInventory,
            notifications: state => state.notifications,
            permissions : state => state.permissions,
            locales : state => state.locales,

        })
    },
    methods: {
        keyHandler(e) {
            if (e.which == 27) {
                this.activeMenu = "";
                this.activePage = "";
                this.adminActivePage = "";
                postNUI("close");
            }
        },
        setAdminActivePage(payload) {
            this.adminActivePage = payload;
        },

        setTime() {
            const date = new Date();
            let Hour = date.getHours();
            let Minute = date.getMinutes();
            if (Hour < 10) {
                Hour = "0" + Hour;
            }

            if (Minute < 10) {
                Minute = "0" + Minute;
            }
            this.minute = Minute;
            this.hour = Hour;
        },
        setDate() {
            const date = new Date();
            let day = date.getDate();
            let month = date.getMonth();
            let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
            if (day < 10) {
                day = "0" + day;
            }

            this.month = months[month];
            this.day = day;
        },
        setCurrentAction(payload) {
            this.currentAction = payload;
        },
        formatInventoryData(data) {
            let tempData = {};

            for (let item of data) {
                if (tempData[item.name]) {
                    tempData[item.name].amount += item.amount;
                } else {
                    tempData[item.name] = {
                        name: item.name,
                        label: item.label,
                        amount: item.amount,
                        metadata: item.metadata
                    };
                }
            }
            let formattedData = {};
            let index = 1;
            for (let key in tempData) {
                formattedData[String(index)] = tempData[key];
                index++;
            }
            return formattedData;
        },
        close(){
            this.activeMenu = "";
            this.activePage = "";
            this.adminActivePage = "";
            postNUI("close");
        },
        async eventHandler(event) {
            switch (event.data.action) {
                case "checkNui":
                    postNUI("loaded");
                    break;
                case "close":
                    this.close()
                    break;
                case "setItemImagesFolder":
                    this.setItemImagesFolder(event.data.payload);
                    break;
                case "setJobInfo":
                    this.setJobInfo(event.data.payload);
                    break;
                case "openMenu":
                    this.activeMenu = event.data.payload.type;
                    if (event.data.payload.type == "admin") {
                        this.adminActivePage = event.data.payload.page;
                    } else {
                        this.activePage = event.data.payload.page;
                    }
                    break;
                case "setCompanyData":
                    this.setCompanyData(event.data.payload);
                    break;
                case "setPlayerInfo":
                    this.setPlayerInfo({
                        type: event.data.payload.type,
                        value: event.data.payload.value
                    });
                    break;
                case "PLAYER_INVENTORY":
                    this.$store.commit("setPlayerInventory", this.formatInventoryData(event.data.payload));
                    break;
                case "COMPANY_INVENTORY":
                    this.$store.commit("setPlayerCompanyInventory", this.formatInventoryData(event.data.payload));
                    break;
                case "setCertifications":
                    this.setCertifications(event.data.payload);
                    break;
                case "sendNotification":
                    this.SendNotification(event.data.payload);
                    break;
                case "PLAYER_MONEY_AND_COMPANY_MONEY":
                    this.$store.commit("setCompanyMoneyData", event.data.payload);
                    break;
                case "UPDATE_COMPANY_MONEY_LOG":
                    this.$store.commit("appendToCompanyMoneyLog", event.data.payload);
                    break;
                case "FIRST_UPDATE_COMPANY_MONEY_LOG":
                    this.$store.commit("resetCompanyMoneyLog", event.data.payload);
                    break;
                case "setPermissions":
                    this.setPermissions(event.data.payload)
                    break
                case "setCompanies":
                    this.setCompanies(event.data.payload)
                    break
                case "setRanks":
                    const data = await postNUI("getRanks");
                    this.setRanks(data);
                    break
                case "setLocales":
                    this.setLocales(event.data.payload)
                    break
                default:
                    break;
            }
        },
        setActivePage(payload) {
            if(payload == 'employees' && !this.permissions.accessToEmployeePage){
                this.SendNotification("You don't have access to this page");
                return
            }
            if(payload == 'ranks' && !this.permissions.accessToRanksPage){
                this.SendNotification("You don't have access to this page");
                return
            }
            if(payload == 'vault' && !this.permissions.accessToCompanyPage){
                this.SendNotification("You don't have access to this page");
                return
            }
            if(payload == 'inventory' && !this.permissions.accessToInventory){
                this.SendNotification("You don't have access to this page");
                return
            }
            if(payload == 'logs' && !this.permissions.accessToClothingPage){
                this.SendNotification("You don't have access to this page");
                return
            }
            if(payload == 'outfit' && !this.permissions.accessToClothingPage){
                this.SendNotification("You don't have access to this page");
                return
            }
            if(payload == 'overall' && !this.permissions.accessToBusinessPage){
                this.SendNotification("You don't have access to this page");            
                return
            }
            this.activePage = payload;
        },
        ...Vuex.mapMutations({
            setItemImagesFolder: "setItemImagesFolder",
            setJobInfo: "setJobInfo",
            setCompanyData: "setCompanyData",
            setPlayerInfo: "setPlayerInfo",
            setCertifications: "setCertifications",
            setRanks: "setRanks",
            SendNotification: "SendNotification",
            setPermissions : "setPermissions",
            setCompanies : "setCompanies",
            setLocales : "setLocales",
        })
    },
    watch: {
        activePage(val, old) {
            if (this.companyData && (val == "employees" || val == "ranks" || val == "vault" || val == "inventory" || val == "outfit")) {
                if (!this.companyData.pageaccess.includes(val)) {
                    if (!old) {
                        this.setActivePage(false);
                    } else {
                        this.setActivePage(old);
                    }
                }
            }
        }
    },
    components: {
        inlinesvg,
        employees,
        employeedetails,
        inventory,
        ranks,
        rankdetails,
        vault,
        logs,
        overall,
        outfit,
        adminlist,
        createmenu,
        jobdetails,
    },
    beforeDestroy() { },
    mounted() {
        setTimeout(async () => {
            const data = await postNUI("getRanks");
            this.setRanks(data);
        }, 2000);

        window.addEventListener("keyup", this.keyHandler);
        window.addEventListener("message", this.eventHandler);
        this.setTime();
        this.setDate();
        setInterval(() => {
            this.setTime();
        }, 1000);
    }
});
if (window.GetParentResourceName) {
    resourceName = window.GetParentResourceName();
}

window.postNUI = async (name, data) => {
    try {
        const response = await fetch(`https://${resourceName}/${name}`, {
            method: "POST",
            mode: "cors",
            cache: "no-cache",
            credentials: "same-origin",
            headers: {
                "Content-Type": "application/json"
            },
            redirect: "follow",
            referrerPolicy: "no-referrer",
            body: JSON.stringify(data)
        });
        return !response.ok ? null : response.json();
    } catch (error) {
        // console.log(error)
    }
};
app.use(store).mount("#app");
var resourceName = "mBossmenu";
