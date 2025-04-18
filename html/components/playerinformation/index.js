import importTemplate from '../../util/importTemplate.js';
export default {
    template: await importTemplate('components/playerinformation/index.html'),
    data: () => ({}),
    props : ["playerName", "playerJob", "playerPP", "theme"],
    mounted (){
    },
}