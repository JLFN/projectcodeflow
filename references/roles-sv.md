# Roller och agenter — hur många du faktiskt behöver

Kort svar: **metoden behöver en agent.** Allt annat är valfri form runt den. Om
ditt verktyg kan starta barnagenter är den rekommenderade formen tre roller, och
exakt en av dem är ny jämfört med ett vanligt upplägg med en verifierare.

## Rollerna

| Roll | Vad den är | Ny? | Antal per enhet | Modell |
| --- | --- | --- | --- | --- |
| Projektledare | Arbetssessionens egen agent, med en namngiven roll och registret framför sig | Nej, det är sessionsagenten | 1 | Din starkaste kapabla modell, vald per projekt |
| Utvecklare | En barnagent per arbetspaket | Nej, vanliga barnagenter | 1 till 3 | Billigare än projektledaren, vald per projekt |
| Oberoende granskare | En barnagent med enbart läsrättighet som återger kontraktet och utmanar det innan arbetet börjar | **Ja** | Exakt 1 per enhet, aldrig en per delmål | En annan modell än utvecklaren om du har en, annars samma i en annan roll |
| Verifierare | Den oberoende verifieringskörning som redan finns i de flesta upplägg | Nej | 1 körning per enhet | Väljs per projekt, precis som verifieringsmodellen redan gör |

Människan är inte en agent. Grinden, registren och loggrotationen är inte heller
agenter: de är ett skalskript och några filer.

## Så konfigureras det

1. **Rollfiler är frivilliga.** En fil per roll ger dig egen modell, eget
   behörighetsläge, egen tidsgräns och egen instruktionstext. Utan dem fungerar
   metoden ändå: sessionsagenten är projektledare och verktygets vanliga
   barnmekanism står för utvecklarna.
2. **En verifieringsmodell per projekt.** Väljer du redan en sådan i dag, fortsätt
   exakt så.
3. **Ett aktiveringsbeslut per repo.** Vad ditt verktyg än kräver innan lokal
   automation får köra, ta beslutet en gång, och låt grinden rapportera när det
   saknas — en inaktiv grind får inte se ut som en godkänd.

## Antal per enhet

| Väg | Anrop | Mänskliga turer under arbetet |
| --- | --- | --- |
| Kort väg, ingen blockerande oklarhet: projektledare + 1 till 3 utvecklare + verifiering | 3 till 5 | 0 |
| Full väg, avstämning behövs: samma plus 1 granskare | 4 till 6 | 0, plus 1 vid avslut om poster parkerats |

## Samtidighet och nästning

- **Räkna med ett platt träd.** Många verktyg tillåter bara en nivå av nästning,
  alltså kan projektledaren inte ha en utvecklare som i sin tur skapar en
  granskare. Varje roll är ett barn till projektledaren.
- **Barn har oftast inget delat minne och ingen kanal till varandra.** De består
  inte mellan enheter, så avstämningsprotokollet är deras enda delade tillstånd.
  Skriv det till en fil, lita aldrig på ett samtal.
- **Parallella utvecklare går bra om modellerna är hostade.** Kör någon roll på en
  lokal modell, serialisera: en lokal inferenstråd i taget, alltså aldrig två
  lokala roller samtidigt.
- **Saknar verktyget barnagenter helt** faller rollerna samman till sekventiella
  turer av en agent: återge, arbeta, verifiera, var för sig, med samma poster på
  disk. Metoden tappar parallellitet, inte korrekthet.
- **Ge granskaren enbart läsrättighet.** En granskare som kan ändra är ingen
  granskare. Tillåter verktyget att ett barn ställer frågor till användaren kan du
  slå på det för utvecklare; låt det vara av för granskaren så att inget avbryter
  en avstämning.

## Att välja modeller

- **Pinna aldrig en modell i reglerna eller i en rolldefinition.** En leverantör kan
  fallera för alla samtidigt, och en pinnad modell tar då hela metoden med sig.
  Välj per projekt vid körning.
- **Oberoendet kommer från rollen, inte från modellen.** En granskare som inte
  skrev koden är oberoende även på samma modell. Föredra en annan modell när du
  har en, men köp inte en andra leverantör bara för detta.
- **Kostnadsordning som fungerar i praktiken:** starkast modell på projektledaren,
  billigast kapabla modell på utvecklarna, mellanklass på granskaren och
  verifieraren.

## När granskaren ska bort

Kör piloten först. Om granskaren gång på gång reser samma oklarhet som
projektledaren redan löst, ta bort den och behåll de fem besluten och grinden. Om
den fångar verkliga motsägelser mellan det skrivna kontraktet och koden, behåll den
och ge den en egen modell. En granskare per enhet är taket i båda fallen.
