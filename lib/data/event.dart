// data/events.dart
import '../models/event.dart';
import '../models/speaker.dart';


// Sample Programs
List<Program> programs = [
  Program(
    id: "f11fe7e0-34d8-4d8e-9e80-3e1ab319b075",
    title: "DevOps",
    events: [], // Will be populated later
  ),
  Program(
    id: "6a33a79a-214c-4365-b3e4-e05f30e17dde",
    title: "AI",
    events: [],
  ),
  Program(
    id: "55f34bce-1f94-4a09-99a9-202ffa593a92",
    title: "Scrum",
    events: [],
  ),
];

// Sample Sessions
List<Session> sessions = [
  Session(
    id: "ccbe8194-b4e2-49e7-af53-0732167522ac",
    name: "Cloud Engineering Session",
    numPlace: 35,
    description:
    "Cloud engineering involves designing, building, and maintaining cloud-based systems and infrastructure. This field focuses on leveraging cloud computing technologies to develop scalable, reliable, and cost-effective solutions for businesses and organizations. Cloud engineers work with various cloud platforms such as Amazon Web Services (AWS), Microsoft Azure, Google Cloud Platform (GCP), and others to deploy applications, manage data storage, ensure security, optimize performance, and automate processes.",
    startDate: DateTime.parse("2024-02-19T08:00:00"),
    endDate: DateTime.parse("2024-02-19T12:00:00"),
  ),
  Session(
    id: "11048e81-056c-4218-a340-0e08adc94293",
    name: "Data Analytics Session",
    numPlace: 35,
    description:
    "Data analytics involves the process of examining large datasets to uncover patterns, correlations, trends, and insights that can inform decision-making and drive business strategies. It encompasses a variety of techniques and tools used to analyze structured, semi-structured, and unstructured data from diverse sources such as databases, data warehouses, social media, sensors.",
    startDate: DateTime.parse("2024-02-19T14:00:00"),
    endDate: DateTime.parse("2024-02-19T18:00:00"),
  ),
];

// Sample Events
List<Event> eventsData = [
  Event(
    id: "67c2327a-da3e-48cc-9d40-3d57813ad559",
    title: "Journey with Azure DevOps and GitHub",
    address: "Conference Room EPIM",
    description:
    "Join us for an immersive Master Class « Enterprise DevOps Journey with Azure DevOps and GitHub » led by the esteemed Hassan Fadili, Azure Cloud & Azure DevOps Consultant and Microsoft MVP.",
    imagePath:
    "https://www.moroccomicrosoftcommunity.com/img/microsoft/Azure-DevOps-and-GitHub-2024-3/big.jpg",
    startDate: DateTime.parse("2024-02-19T00:00:00"),
    endDate: DateTime.parse("2024-02-19T00:00:00"),
    programId: "f11fe7e0-34d8-4d8e-9e80-3e1ab319b075",
    program: programs[0], // DevOps
    sessions: [
      sessions[0],
      sessions[1],
    ],
  ),
  Event(
    id: "8059e006-698a-47b6-94e2-5f9023c784d4",
    title: "Global AI Bootcamp 2024",
    address: "Tanger in Morocco",
    description:
    "Morocco Microsoft Community is very honored to announce that we again will host Global AI Bootcamp 2024 Event on April 26th, 2024 at Technopark Tanger, Morocco. During this event several sessions will be provided with demos and eventual workshops by community peers and speakers MVPs and MCTs from Morocco Microsoft Community and others.",
    imagePath:
    "https://www.moroccomicrosoftcommunity.com/img/microsoft/Global-AI-Bootcamp-2024-2/big.jpg",
    startDate: DateTime.parse("2024-04-26T00:00:00"),
    endDate: DateTime.parse("2024-04-26T00:00:00"),
    programId: "6a33a79a-214c-4365-b3e4-e05f30e17dde",
    program: programs[1], // AI
    sessions: [],
  ),
  Event(
    id: "8daeb17d-9e15-44ec-94a6-9ada592e54b4",
    title: "Jit Event",
    address: "Lhih",
    description: "<p>description<br></p>",
    imagePath: "assets/images/404ErrorPage.png", // Placeholder image
    startDate: DateTime.parse("2222-02-21T02:12:12"),
    endDate: DateTime.parse("2123-03-04T12:42:01"),
    programId: "55f34bce-1f94-4a09-99a9-202ffa593a92",
    program: programs[2], // Scrum
    sessions: [],
  ),
];

// Link events to programs
void linkEventsToPrograms() {
  for (var event in eventsData) {
    var program = programs.firstWhere((p) => p.id == event.programId);
    program.events.add(event);
  }
}

// Initialize data
void initializeData() {
  linkEventsToPrograms();
}
