import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log("Suppression des projets existants...");
  await prisma.project.deleteMany({});

  console.log("Insertion des projets de seed...");
  await prisma.project.createMany({
    data: [
      {
        id: "1",
        name: "Residence A",
        status: "PUBLISHED",
        amount: 120000,
        createdAt: new Date("2024-01-10T10:00:00Z"),
      },
      {
        id: "2",
        name: "Loft B",
        status: "DRAFT",
        amount: 85000,
        createdAt: new Date("2024-02-05T12:30:00Z"),
      },
      {
        id: "3",
        name: "Villa C",
        status: "ARCHIVED",
        amount: 240000,
        createdAt: new Date("2023-11-20T09:15:00Z"),
      },
      {
        id: "4",
        name: "Immeuble D",
        status: "PUBLISHED",
        amount: 410000,
        createdAt: new Date("2024-03-01T08:00:00Z"),
      },
      {
        id: "5",
        name: "Studio E",
        status: "DRAFT",
        amount: 60000,
        createdAt: new Date("2024-04-18T14:45:00Z"),
      },
    ],
  });

  console.log("Seed terminé avec succès !");
}

main()
  .catch((e) => {
    console.error("Erreur pendant le seed :", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
