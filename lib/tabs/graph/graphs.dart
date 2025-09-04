import 'package:boinctasks/main.dart';

var gGraphData = [];
var gGraphSelected = [];

class Graphs {

  dynamic newData(dynamic state, computer, data)
  {   
    var retProcess = process(computer, state, data);
    return retProcess;
  }

  List process(String computer, state, data)
  {
    var graphArray = [];       
    try{
      var stats = data['statistics']['project_statistics'];
      if (stats != null)
      {
        var listItem = [];
        var len = stats.length;
        for (var i=0;i<len;i++)
        {
          var projectName = "?";
          var item =  stats[i];
          if (item == null) // happens when there is a single project
          {
            item = stats;
            i = len;
          }
          var url = item['master_url']['\$t'];
          var ret = state.getProject(url);

          if (ret != null)
          {
            projectName = ret;
          }
          var dailyStats = item['daily_statistics'];
          var lens = dailyStats.length;
          var listItems = [];
          for (var s=0;s<lens;s++)
          {
            var items = dailyStats[s];
            if (items == null)
            {
              continue; // happens when there is only one item
            }
            var day = items['day'];
            if (day == null)
            {
              continue;
            }
            var seconds = double.parse(items['day']['\$t']); // time in seconds            
            var uTotal = double.parse(items['user_total_credit']['\$t']);
            var uAvg = double.parse(items['user_expavg_credit']['\$t']);
            var hTotal = double.parse(items['host_total_credit']['\$t']);
            var hAvg = double.parse(items['host_expavg_credit']['\$t']);
            listItem = [seconds,uTotal,uAvg,hTotal,hAvg];
            listItems.add(listItem);
          }
          listItem = [computer, projectName, listItems];
          graphArray.add(listItem);
        }
      }      
    }catch(error,s)
    {
      gLogging.addToLoggingError('Graphs (process) $error,$s');      
    }
    return graphArray;
  }

}