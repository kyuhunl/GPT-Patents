# National Inventors Hall of Fame
invent.org
639 unique inventors, 589 unique patents (153 matched with PatentsView, rest seem to be before 1976. The older patents can be looked up on Google Patents)
15 inventors have no patents listed

# Other sources of significant patents
- Kelly et al. (2021) has a list of 245 historically significant patents collected from various sources (Appendix Table A1)
- UK: The King's Award for Enterprise in Innovation: Capponi, Martinelli, & Nuvolari (2022)
- Lemelson-MIT Inventor Archive (https://lemelson.mit.edu/resources/inventor-archive)
    - No direct patent linkage
    - Maybe I can scrape the text description and match to patent using text analysis
- Patent-paper pairs
    Great scientific discoveries to patents 

# Hall of Fame + Kelly et al. (2021)
Total 747 Patents (87 overlap)

# Building my dataset
Start with a clean data of patent data (master file)
and then add on other variables
added data may be available for some, not for others, so you need a platform to work on

Platform: PatentsView patent data (1976-2015 or maybe even 2019 to look at 5-year citations)

Variables: CD index (shouldn't be too hard to calculate)
Actually, it's hard to calculate. Fuck! Remember how long it took to calculate CD index for just the significant patents? I have to do that again with the full sample
Let's look at the Funk paper to check how they did it: probably a more efficient way. Should be manageable to run by next meeting.
Kogan et al. measure: on GitHub(https://github.com/KPSS2017/Technological-Innovation-Resource-Allocation-and-Growth-Extended-Data)



- Got g_patent.tsv from PatentsView (8701569 rows)
(I want to filter by utility patents only, but the patent_type column seems to be misclassifying many patents. I will filter after investigation)
- Filtered by patent_date <= 2020 (7627229 rows)
- Dropped patent_type, wipo_kind columns