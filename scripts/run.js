async function main() {
  const gameContractFactory = await hre.ethers.getContractFactory(
    "HoopDestroyerGame"
  );
  const gameContract = await gameContractFactory.deploy(
    ["LeFuckYouThree James", "Casual Caruso", "Carpincho Buckets"],
    [
      "QmcQsYwTkkKi4pjn8uDreULckiTnmbXha3yjYFYkwFWpW3",
      "QmYR2rLjcpf6hzk9Rs51qU5m3cXD7ceLXPR5aP8AbMEn3j",
      "QmRk39yvzt4dCdkAqqBX9Xhp5t1aymmj1HaigHePcnqUqL",
    ],
    [100, 200, 269],
    [236, 100, 69],
    "Ball Driller",
    "https://i.ibb.co/JsGP7N3/image.jpg",
    2500,
    35
  );
  await gameContract.deployed();
  console.log("Contract deployed succesfully to: ", gameContract.address);

  let txn;
  txn = await gameContract.mintPlayerNFT(0);
  await txn.wait();
  console.log("Minted NFT #1");

  txn = await gameContract.mintPlayerNFT(1);
  await txn.wait();
  console.log("Minted NFT #2");

  txn = await gameContract.mintPlayerNFT(2);
  await txn.wait();
  console.log("Minted NFT #3");

  txn = await gameContract.attackBoss();
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  console.log("Done deploying and minting!");
}

async function runMain() {
  try {
    await main();
    process.exit(0);
  } catch (err) {
    console.log(err);
    process.exit(1);
  }
}

runMain();
