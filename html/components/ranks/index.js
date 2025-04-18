import importTemplate from '../../util/importTemplate.js';
import inlinesvg from '../../util/inlineSvg.js';
import playerinformation from '../playerinformation/index.js';
export default {
    template: await importTemplate('components/ranks/index.html'),
    data: () => ({
   
        filteredRank : ''
    }),
    methods : {
        ...Vuex.mapMutations({
            setSelectedRank: 'setSelectedRank',
        }),
        RankDetails(rank){
            this.setSelectedRank(rank)
            this.setActivePage('rankdetails')
        },
        playerCountInRank(rank){
            let count = 0
            this.companyData.employees.forEach((employee) =>{
                if(parseInt(employee.rankLevel) == parseInt(rank)){
                    count = count + 1              
                }
            })
            return count
        },
    },
    props: ['setCurrentAction', 'currentAction', 'setActivePage'],
  
    components : {
        playerinformation,
        inlinesvg
    },
    computed : {
        ...Vuex.mapState({
            playerInfo : state => state.playerInfo,
            jobInfo : state => state.jobInfo,
            companyData: state => state.companyData,
            ranks : state => state.ranks,
            locales : state => state.locales,

        }),
        formattedJob(){
            return this.jobInfo.label +'-'+this.jobInfo.grade_label
        },
        getFilteredRanks(){
            if(this.filteredRank.length > 0){
                return this.ranks.filter((rank) => rank.label.toLowerCase().includes(this.filteredRank.toLowerCase()))

            }
            return this.ranks
        }
        
    },
}