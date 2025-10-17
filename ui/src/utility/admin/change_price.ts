import { Transaction } from "@mysten/sui/transactions";

export const changePrice = (packageId: string, listHeroId: string, newPriceInSui: string, adminCapId: string) => {
  const tx = new Transaction();
  
const newPriceInMist = BigInt(Math.round(parseFloat(newPriceInSui) * 1e9));

  tx.moveCall({
    target: `${packageId}::marketplace::change_price`,
    arguments:[
      tx.object(adminCapId),
      tx.object(listHeroId),
      tx.pure.u64(newPriceInMist),
    ],
  }); 
  
  return tx;
};
