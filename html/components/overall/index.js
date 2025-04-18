import importTemplate from "../../util/importTemplate.js";
import inlinesvg from "../../util/inlineSvg.js";
import playerinformation from "../playerinformation/index.js";
export default {
  template: await importTemplate("components/overall/index.html"),
  data: () => ({
    newLogo: null,
  }),
  methods: {
    ChangeTheme(value) {
      postNUI("changeTheme", {
        theme: value,
      });
    },
    UploadNewLogo() {
      if (this.newLogo) {
        postNUI("UploadNewLogo", {
          url: this.newLogo,
        });
        this.newLogo = null;
      }
    },
    DeleteBusiness() {
      postNUI("DeleteBusiness");
    },
    SecondsToDate(seconds, includeHours) {
      const date = new Date(null);
      date.setSeconds(seconds); // specify value for SECONDS here
      let day = date.getDate();
      let month = date.getMonth() + 1;
      let hours = date.getHours();
      let minutes = date.getMinutes();
      if (minutes < 10) {
        minutes = "0" + minutes;
      }
      if (hours < 10) {
        hours = "0" + hours;
      }
      if (day < 10) {
        day = "0" + day;
      }
      if (month < 10) {
        month = "0" + month;
      }

      let formattedClock = `${hours}:${minutes}`;

      return `${day}.${month}.${date.getFullYear()} ${
        includeHours ? formattedClock : ""
      }`;
    },
  },
  props: ["setCurrentAction", "currentAction", "setActivePage"],
  mounted() {},
  components: {
    playerinformation,
    inlinesvg,
  },

  computed: {
    ...Vuex.mapState({
      playerInfo: (state) => state.playerInfo,
      jobInfo: (state) => state.jobInfo,
      companyData: (state) => state.companyData,
      ranks: (state) => state.ranks,
      companyInventory: (state) => state.companyInventory,
      vaultData: (state) => state.vaultData,
      vaultDataHistory: (state) => state.vaultDataHistory,
      locales: (state) => state.locales,
    }),
    getMostContributors() {
      let newData = [];
      this.vaultDataHistory.forEach((data) => {
        const dataExist = newData.find((d) => d.identifier == data.identifier);
        if (dataExist) {
          dataExist.amount = dataExist.amount + data.amount;
        } else {
          newData.push({
            identifier: data.identifier,
            amount: data.amount,
            name: data.to,
            avatar: data.avatar,
          });
        }
      });
      newData.sort(function (a, b) {
        return b.amount - a.amount;
      });
      return newData;
    },
    getCardBG() {
      if (this.companyData.theme == "blue") {
        return `./assets/images/card-container.png`;
      } else {
        return `./assets/images/${this.companyData.theme}/card-container.png`;
      }
    },
    getBoss() {
      let boss = "";
      this.companyData.employees.forEach((employee) => {
        if (employee.rankLevel == this.companyData.bossrank) {
          boss = employee.name;
        }
      });
      return boss;
    },
    formattedJob() {
      return this.jobInfo.label + "-" + this.jobInfo.grade_label;
    },
  },
};
