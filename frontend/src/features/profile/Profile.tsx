import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import OverviewTab from "./OverviewTab";
import DataTab from "./DataTab";

export default function Profile() {

  return (

    <Tabs defaultValue="overview" className="">
      <TabsList>
        <TabsTrigger value="overview">Overview and scrape</TabsTrigger>
        <TabsTrigger value="mydata">My data</TabsTrigger>
      </TabsList>
      <TabsContent value="overview"><OverviewTab /></TabsContent>
      <TabsContent value="mydata"><DataTab /></TabsContent>
    </Tabs>
  );
}
