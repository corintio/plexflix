#!/usr/bin/env ruby

# <bitbar.title>Plex Bar</bitbar.title>
# <bitbar.version>v0.0.1</bitbar.version>
# <bitbar.author>Corintio</bitbar.author>
# <bitbar.author.github>corintio</bitbar.author.github>
# <bitbar.desc>Monitors your Media Server services</bitbar.desc>
# <bitbar.image></bitbar.image>
# <bitbar.dependencies>tautulli</bitbar.dependencies>
# <bitbar.abouturl>https://github.com/corintio/plexflix/tree/master/plexbar</bitbar.abouturl>

require 'json'
require 'base64'
require 'open-uri'
require 'net/http'
require 'date'
require 'yaml'

# External files
CONFIG_FILE="~/.plexbar.yml"
CACHE_FILE="/tmp/plex-info-cache"

# Icons
PMS_ICON="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"
TAUTULLI_ICON="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAA3hJREFUOBFFVF1MXEUU/mbm3gWyEJYfs/wUdVl0aQvdGtCWbfCBRuWBBxpZm9Q09cGXkrYmGmNSEx8MatO0VatGmlRNY0IkmxoiFtDUYFq6VRtrC+K2QKBKgaXWpXUL3b27M9Mz8NCTnJwzd+Z88835uQxrIshI49bW1YWg2B5yt5HWkDLSSWhEHy/CV0PRsYu0JglTTEQyhMmJRGRDQ4N9L5X+iGneKQSH1hpKqdWjnHMIzjA2T+vb+BwoPgD8nKVNYdAJIyxGx699LzhvlVKCMZaheM4YuNknPDmehD64TdrrSji6h/HD6J+lbQbEUEdWseN5ubm7Cgry05awuJPJWCZYE/1cATa9DP5chRQH2xdV8/oFR2hPYOBSpghYHLSqA4FG27b33f4vgbk/pi3C4xvqgmv0DQJxdMguO3SRVHwhkWPPLFK6vHp/q3/j1zw/N3938t4yfI9VOZFIRBw9egx/TfwNIQQ0BZs3Zm4w7GpycD5WiOePVPETl3Mym7wcN5b4HqugwB0avfo7Dr3/Lu/o6EAymcSZgUHErk+hdp0Hw6MSb4YdVBan0fZFIfHj2OzRLK2IFrCVp1IpUypMTk7yRCIBk0S/vxoLN2cwPJ2HwKMOttcvozfqprcwbClRWMlQcinLxNAvCj1Fb3nLKvL6B8/qL098xiyXjRd37MDc/Dz2Nk6g8wUPfp1gOHbaQtN6F1a0DSWlpkqZ190XpaXeMPkV3pJCOfW/zc9+1wt/cCteaQvhWfdJlLgXcJpa54qrHDl344hdu47yikqptDYsYpxxPWKa5MpSVoWfcqO5qRH/fPsqrPh5pEsP4I77NUjPFqjYRVT5avDSzp0Yu3oZtmUKhihaQxufRvEm/c7LtXrmpCc73l2vT3VCf9j1tk6lHZ3NZvXIhaju6enRs7OzeuX+iuzqes9kULe3tz9jDUXHLwHBTyuL9T6v546ML9k49GO1iLnOIRgaoaQq9PZ+g2BwM8rKypRlWVmfz+cigE/6+vp+W+UBWK8f/8mqSWcCrVNxhThzOxsyc7ylpWW1U+mwGTR1699bLn+13/XB4SNDtH6D1PTJ2lQBDTa1zMcoZ3vrHyF+TMBlW6ZasMnSzYiOnDMx3aT7SR8O00MQYHuovunmXbabKd3MOHvCRFBvTNB0Xqh90n+qv7//F/ONZPUX8ACCi2juYZgsCAAAAABJRU5ErkJggg=="
SONARR_ICON="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAACXBIWXMAAAsTAAALEwEAmpwYAAABWWlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS40LjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyI+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgpMwidZAAAC90lEQVQ4EW1TW0hUURTdd7yO9lX2VVE2RBmJZJH5IF+hEH30ENMoQimCSPzwo8CgaBA0DBtQKTBRIe2jUosgAiUtrUgj00zJRzKOOs6M6cydcebO487s9r7i2EcbFmefw1lnv9YBINMDaHhls1qtiZIk1ROGCBaC1eFwjDidzgbyk9duEUevD3PCztLSksHn8yGb3+9Ht9utgn22QCCAdru98X+PACSefd3Y1IyS5Ah6ZNlPURW6HLQ7HEH23R6Pnx5U2js7EdIKetcfUdd5k8lwz1CHABny7fKboamJX+hyuVCWvSpWV1fROPMba6qr6E6uXHbrLk5NTKiZCFTzwS0xMSNOhz2kr6wWHkbuE3YMdUFxchzs0e0GjSDA3IIZng/Pwnh8JhTO98ODqgpl565YcWVlJQ3sklTL9Xl9Pv/o928IReWYfP8ZRQKE7EsIOcWqn1L5BKGwDAc+9aM/EPCHQiGkxjYBdXaQm8R1ko+l166qhPSGbswa8GLWoBfTmz/gJnrwfN4p/LO8zETF6/VSv6QxkYJvUxQFaBW02ijYG7cfIPsCaA6lgyeoEA0hOiEV5DPX4UD8ZoiOigZFCWgoKHN0IqUaHiMIABEa2mr4GEAgctioF6IYQYfhExDojMlWURR5g5zJnHkRoKcVfCOfiRCpIjA2APDqEcwYTcCRyVCr1fI6yz2op1SQ5zwzPYW6kxcwtaoVddzE/BKEc6W4nfxMQzvC8QL8+WMYqX61icRt0VA3m0h9nJnmZccLNB7OhS9fByE2KQFKYjxQutUDCRkp0NfbDZB6Ap62tVEWPrU6ynhNlaS42vYOUhjkyKcLL4bedb3FBbMZSYU0HQkXLRb8+L4Hiy5foTu5MivWZrM1cw0blpT/5sadCjTNGhWeMymRxxpi0NiCPireZrUEKmtqEY7m9RFxrZ3//qrpycm6YDCELBL+VCxnBs+cz9hMptkWIquTC3P1+o1R0o88QqJ6TBglSAQXYZyyaCHZH1tPeZ38F9gqHuoZR+ePAAAAAElFTkSuQmCC"
RADARR_ICON="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAAztJREFUOBFlU11oFFcU/mZmN5ukmgSLgvbFSK1WUsQHzYYY0ELVFq0tJC0IfVD6A31oH6wiFhRFRLQoxuw2a/tQiFQU05ag2WQTI/5EY+ODqW7NJpLEWPoiO5ndzOzOzO7c03NHNwo9cLgf557v3HPv/Q7AdvEiNLlKc+NYa6c6I9b00H3r6T3Ld8b50c6o24N1z7Ne4ZTIRNDSd1vbvcw0EXlU8ARlLcd3iWXMyzwlfbg9RtcQkIVKXPCuduUIene0bKeRRxPkuK6r63rBMGaE9BnGDgdHxyfFZ9sbqOsQEszxi6iy0o1TSlvf5Mebvt44ZXfsXyZS4xPB6uqqQFmwTJE+v6oqMDU5EWxaVUv1739u37e/ee/qcSUiuaDBLWu/+xDUfXVQkP3E+/vCJ9QUXkNX4r3UFo1RayRGiUQv1b1TRx3nzvHB5N28Myz2NnPjN9fXo+sgIgf276FMNuvq2RzlTYOGL58hWbu+GrRxCXx8qbOTbNsmwzDINC33xLEj9Mf3+DEw9hiNq5ubUFlerpjmLJxACHXv7sS/13TUFH6BqpiYEnvxxvoP4DoOhBAIhYJK3Zowkh1oVD0Ny6tqFnA/gr9SkQfDyc1icUUKFeUKJy/AipohUC4NoWhQOIWE0CrmzYcawlv+I8q38E3yuYgKwUuBsZQHY46Qwqn813P2Aqqah/GsoXNl1ZP7KnlQKl7HWCbMLT+DW6jE1LOFCAaDULQAn05+rpk1IByMqSvfxOBf924hxw+kaRrKQiH0J+JYsWk3tn1pYNtXI6jdGsXAhWMoK8xACVbCdlwaYc7yWgyCbm9et5u/MTFww5fbr+fP09LapRTv7qZTrVE6ebqNenp66bW3G+h66yKi2RGv7/qQ2PMRX+jWhrB/pYHjiO37dhedjp7Ns7y8ZDJJxWKRLMtkt8grFij5KEXNjfC6jyK/74vN1P8Dfnr5HizLy4eR+HTLano4+lg8l3K6mGEZS9f1dFFK+UFqQjS3tFDXYfSXpDw3EHJA9D8jZ0X2Hyk2KhQFZUzbd4llTO6l7575+X/DNDdV3FOuD+H82G/t1vSdBzzKTo7dfDL0MJ/6PZaLo6HUdonzHy7qBnX7KhkoAAAAAElFTkSuQmCC"
SEEDBOX_ICON="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"
TRANSMISSION_ICON="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAA1VJREFUOBFVU11MFFcU/u7MMLvKdrGysCAgBhVQE60G/AlgooltbNPEPhjTpIlF2ibaVIl9UjRsk/rSmJo09S+KBrFPfehPWqBY26RsVoxoatOwNjUUtqssZlnWnVmYnb/Te0d46E3O3Hu/853vnnvOHQY+iEhijLkL6/W2ZXXMJZNtlparIALUkpLU0qrKqFLku8Z5f/4vRgQLQAzTss6mosM0fuok3eO6wwsm1uNdJyg1/BuZpvn5C/bCwYub3MzMD8b3373xsP2QqwLOkoPvMCVUxrif2em0O9/bRyYgb+y5Ki3Z99ZAsLT09cVY5HT97PS1HuoH5h/13XAdxyGrUCDbtj2zzAIJ7NFXN13BSV29QpqmnRMCCr/C+omfBj+eONRBxYBPz2TYbCYDXhT4/H7vkIJhQBRI+ARn7L333brq6s4CUY/0LJV61/rlNniutly/kmWPdSJWVobY3j3I53LIaxpib+5FLBRC9qOjkBtXMZlzzVtDyE5NtSv5xGSrNvQjeCUZzT6BrzaEZfvextzUUxj5PHjVEaxZiaXN22D0fwM3MQEWhJzr/xbK/gMtipV9Xm79HgdrqJXcvybh6z6Mqs7jmL57F3M8AyHwUnsHKrbvwGRpCEZ3BPK6OtjxcZjZ2XLFcV1HlBoEEvdUGtbBsm1Y/AHwAnkCtksepjQ0cBpPVX7RecclR2HFxRNq2/Z6c3hE+CCFw9BnZjCf/BfZB/c5IMG3vBTa6tWQysOCAko8JnXbZrBAYFKSKisH/Tt3CWXC7p2gQAAaFzBGR8G6ToGdOAnjwSj0dBrgPraHc3Nw/btehRwODyj2mjW9xpambp5Uib2lyXX9fknmqS8/8iHMTZuELNSWFu9kh2eDzU0uu/WrOt+8tfByff1NZQNjmXtjY2fCFy98Nn6my0o3NRcxEk3hI1wh2guKx70t8f9F+rrPqjv/pe95Y2OkjrFpRCIRjxy9c+d6/PIlGuL8AaDAzeKvzhEm1gITvvilixQdifUKRf4IGfM+fBLAYDR6OvD0yellj/8usv94CDuZEDCUqhooG1/B7Nq19lzlik9fa2v7ROBe7OJCzLzn9MXISHWtrn+g6vpuyTBqPL/fnzSDwZ//UdWeY62tCRG4yP8PUtanvCymhNMAAAAASUVORK5CYII="

STATE_ICON = {
  "playing" => "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAAplJREFUOBFlUz1oFEEUnje3Sa4wMSpaJbt7uxsvslgdYrtaqM0FQRtFCAhiJYiKSMA+RcDGQiysRAV/EAuFgLIIlgabiAmX8+5yqQ4koEk4b2bH781uIOCD2Tfve7/z3lsSOREYnywMwyNCqWtGUB2An+O0DtV7UupxY2OjW9iCCVMqBMNC6Hl3yIhFIjqNcD+FEZ8N0TIJM0aCZskZunVwfD/92txMYc8k+cOZReT5T6bDyARe5aHrugcY20vx4Xhf5PrzVdiEnv9mrw7O3hw7R657ZY/CiaJoJEkSJxHC2cUrbqWeB6ksWCwIAneqEiBqDsRxPAyFLa1w4jtXSRyQscD37x0NQk4YS9L6RpZloq8H91lZLpe5H1no+rMwvMl3HMZKjUbjL7hotlrzSustQfI2otMM1O+63e4Olzs6OsrGIBobLjkPEOhRLgvFINvkMr2A4QyXN4XLUmEkRJrfjDQDjcpI0nU07Yfv+yehyXq9Xv48Ml+llIfs+6QUtjTrmuQB8MX0ULvBRhBVYRiwpt/v26lJQwOWOcAG7KZZsJQWnJekxGsilmSmQ7z7Oe6liYkJzSD7oHd9BDCfINUZTNNUiYRvSJ+J4YEevFxrt2qrnU6zVqsNAdaw4aaCzAV8PopgMjhRxUgCz7vKMN5aLvg484JsKbu60PfPVwPszWTljH0PmvQMDblktIobnc53OHGnNbLajtvJpCn3V/HeyMy0s8wsNjutszZAAod1z/8mScba6IvNdvs1AvxHyHwOz/2A8rvl7e1jy73eHw7A5WnewJ2trVdDJaeulFpFF54akeFHwiAwBfTksuM4x5VWqVMemVlZWfnNvraC3SDgoshyF6M7hcOQHSWm+UWQWVhrtd5asEj8D30S9wRVOdHHAAAAAElFTkSuQmCC", 
  "paused" => "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAAUVJREFUOBF9k00yBEEQRgsLrmAxoWdng2DvAByEG+AcbMZuVmZOQHAHRHAB005hIfhedX4V1R1NRrzO7PypzKquTqmT9dCoA3ErWvETYM8EMUupKYYiN8JFz7LnAbb95Fjq2vQkL0l3YuqMSuNbCHLI7Yk7X/S8KdGh10Xvl4JFyiTsy51lZtnW81hsBdj4LJ4knwkHxgI7jkqfh29XGoifCUsjA9+M8U7Ei1iJTYF8dyonkYjYR86HeBWnLDAR7wJZ69To0zHrN2VNhgc0WvmfkwU+xV4kedyxGses95XUssC9OBKN+BLIRqfyljyyfeQ04lA8iHw9WXXBSwifjE/312dcKkZNudq+SFySWphweE5X8lF8XSdi+yozyXQYDJ87P9bxuoMnoQN3Yx5g4xt2LrXFUBL74tdto4CiVfjKnvWea34BWShPN2evMNsAAAAASUVORK5CYII=", 
  "buffering" => "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAACXBIWXMAAA7EAAAOxAGVKw4bAAABWWlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS40LjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyI+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgpMwidZAAABaklEQVQ4EY2TyypFURyHN4cRSlF0lEsmhiaewIgXoAwMztwDeQeZSDFTSiYoMTJxK2SgMHD3fWuv/24fUX71rfW/rr322msXRakhpnv4+ifW2lN0OaA3eIABuAHVAS6o6vYwvrX2JDXyvMD8ATPQCz5hMKNtzNwnWKtSbywwSsDkvJk/NEfcmrGcT71uT9QxrCcrr/7DXsM/zbF6X3UWSyR970kYh42M9gSYWwYV55ec2IHODtxBEy7gHEbgFnYhVO9Jsc6c6WE+hEvwaS24hiPoAxW1bdtwe+oZrmAaTsBid3MAj6CitvTyGKuu5oKpWlbbJnMqakuPMQ5kFtvCxZzxk8ZnNWbOGhU9yYkV9/D2oRs2wQbRNmbOGhU95W0i4Hu+wgpsgY36or0N5vSboBrVgOH19JD8jDa8gFdbtI2Ze4K2q4yffqIzZou8qu8QzTEbM2eNtf541Xt4IP0GkA1ekt8wp6xNh/gNyddfpPZ40EwAAAAASUVORK5CYII="
}

$cache = Hash.new
$error = false

if ARGV.length != 0 && ARGV[0] == "refresh"
  File.delete(CACHE_FILE)
  exit
end

class Integer
  def to_filesize
    {
      'B'  => 1024,
      'KB' => 1024 * 1024,
      'MB' => 1024 * 1024 * 1024,
      'GB' => 1024 * 1024 * 1024 * 1024,
      'TB' => 1024 * 1024 * 1024 * 1024 * 1024
    }.each_pair { |e, s| return "#{(self.to_f / (s / 1024)).round(1)} #{e}" if self < s }
  end

  def to_speed
    "#{self.to_filesize}/s"
  end
end

class TautulliPlugin
  attr_reader :name
  
  def initialize(config)
    @name = 'tautulli'
    @output = Hash.new
    @base_url = config["url"]
    @api_key = config["apikey"]
  end

  def server_name
    @servers_info ||= tautulli("get_servers_info")
    @server_name ||= @servers_info["data"][0]["name"]
    @server_version ||= @servers_info["data"][0]["version"]

    out = ["#{@server_name} | image=#{TAUTULLI_ICON} href=#{@base_url}/home"]
    out << "#{@server_version} | image=#{TAUTULLI_ICON} href=#{@base_url}/home alternate=true"
    out
  end
  
  def num_sessions
    sessions.size
  end
  
  def total_bandwidth
    activity = tautulli("get_activity")
    @total_bandwidth ||= activity["data"]["total_bandwidth"] / 1000
    # Main icon / Tautulli
    if num_sessions == 0
      out = ["No sessions in progress"]
    else
      out = ["Total Bandwidth Used: #{@total_bandwidth} Mbps"]
    end
    out
  end

  def plex_sessions
    out = []
    sessions.each do |session|
      out = out + format_session(session)
    end
    out = ["---"] + out if out.size > 0
    out << "---" if out.size > 0
    out
  end  

  def recently_added
    out = []
    recent = tautulli("get_recently_added", "count=20")
    if recent["data"]["recently_added"].size > 0
      out << "Recently added | color=white"
      recent["data"]["recently_added"].each do |item|
        out << "--#{get_title(item)} | href=#{@base_url}/info?rating_key=#{item["rating_key"]}"
      end
    end
    out
  end

  def libraries
    out = ["Libraries"]
    libs = tautulli("get_libraries")
    libs["data"].each do |lib|
      count = lib["count"]
      count += "/#{lib["parent_count"]}/#{lib["child_count"]}" unless lib["section_type"] == "movie"
      out << "--%-15s  %15s | color=white font=Courier " % [lib["section_name"], count]
    end
    out
  end
  
  private

  def tautulli(cmd, params = "")
    @output[cmd+params] ||= (
      content = URI("#{@base_url}/api/v2?apikey=#{@api_key}&cmd=#{cmd}&#{params}").read
      JSON.parse(content)["response"]
    )
  end  

  def sessions
    activity = tautulli("get_activity")
    @sessions ||= activity["data"]["sessions"]
  end

  def get_title(item)
    return "#{item["title"]}" if item["media_type"] == "clip"
    return "#{item["title"]}" if item["media_type"] == "movie"
    return "#{item["full_title"]}" if item["media_type"] == "show"
    return sprintf("%s - %s", item["parent_title"], item["title"]) if item["media_type"] == "season"
    season = item["parent_media_index"].to_i
    episode = item["media_index"].to_i
    title = sprintf("%s - S%02dE%02d", item["grandparent_title"], season, episode)
  end
  
  def format_session(session)
    title = get_title(session)
    href="#{@base_url}/info?rating_key=#{session["rating_key"]}"
    user_url = "#{@base_url}/user?user_id=#{session["user_id"]}"
    icon = STATE_ICON[session["state"]] || STATE_ICON["buffering"]
    out = ["#{title} (#{session["progress_percent"]}%) | href=#{href} templateImage=#{icon}"]
    out << "--User: #{session["friendly_name"]} | href=#{user_url}"
    out << "--Quality: #{session["quality_profile"]}"
    out << "--Bandwidth: #{session["bandwidth"].to_i / 1000}Mbps"
    out << "--#{session["platform"]}/#{session["product"]}" if session["platform"] + session["product"] != ""
    out << "--#{session["player"]}" if session["player"]
  end
  
end

class PVRPlugin
  attr_reader :name

  def initialize(name, config)
    @output = Hash.new
    @base_url = config["url"]
    @user = config["user"]
    @password = config["password"]
    @api_key = config["apikey"]
    @name = name
    if name == "sonarr"
      @release_field = "airDate"
      @item_type = "episodes"
      @period = 6
    else
      @release_field = "physicalRelease"
      @item_type = "movies"
      @period = 30
    end
  end

  def missing
    @missing ||= call_api("wanted/missing")
    return if @missing["totalRecords"] == 0
  
    out = ["#{@missing["totalRecords"]} missing | href=#{@base_url}/wanted/missing"]
    @missing["records"].each do |record|
      out << "--#{build_title(record)} | color=white"
    end
    out << "--More... | href=#{@base_url}/wanted/missing" if @missing["totalRecords"] > 10
    out
  end

  def calendar
    now = Date.today
    dstart = now.strftime("%F")
    dend = (now + @period).strftime("%F")
    @calendar ||= call_api("calendar", "&start=#{dstart}&end=#{dend}")
    return if @calendar.size == 0
  
    out = ["Upcoming #{@item_type} | href=#{@base_url}/calendar"]
    @calendar.sort! {|x,y| (x[@release_field]||"") <=> (y[@release_field]||"") }
    @calendar.each do |record| 
      if record[@release_field]
        airdate = Date.parse(Time.parse(record[@release_field]).localtime.to_s)
        if (airdate - now) > 6
          date = airdate.strftime("%b %e")
        else
          date = airdate.strftime("%a")
        end
        title = sprintf("%s - %s", date, build_title(record))
        if record["hasFile"] 
          out << "--#{title}"
        else 
          out << "--#{title} | color=white"
        end
      end
    end
    out
  end
  
  private 
  
  def call_api(cmd, args = "")
    @output[cmd+args] ||= (
      options = @user ? {http_basic_authentication: [@user, @password]} : Hash.new
      content = open("#{@base_url}/api/#{cmd}?apikey=#{@api_key}#{args}", options).read
      JSON.parse(content)
    )
  end

  def build_title(record)
    if @name == "sonarr"
      season = record["seasonNumber"]
      episode = record["episodeNumber"]
      title = sprintf("%s - S%02dE%02d", record['series']['title'], season, episode)
    else
      title = record["title"]
    end
  end
end

class TransmissionPlugin
  attr_reader :name, :web_url

  def initialize(config)
    @name = "transmission"
    @base_url = config["url"]
    @web_url = "#{@base_url}/web/index.html"
    @uri = URI.parse("#{@base_url}/rpc")
    @user = config["user"]
    @password = config["password"]
    @output = Hash.new
  end

  def speed
    resp = call_rpc("torrent-get")
    if resp["arguments"]["torrents"].size == 0
      out = ["No downloads in progress"]
    else
      up = down = 0
      resp["arguments"]["torrents"].each do |torrent|
        up += torrent["rateUpload"]
        down += torrent["rateDownload"]
      end
      out = ["↓%s  •  %s↑" % [down.to_speed, up.to_speed]]
    end
    out
  end

  def queue
    resp = call_rpc("torrent-get")
    out = []
    if resp["arguments"]["torrents"].size > 0 
      out << "%d downloads" % resp["arguments"]["torrents"].size
      torrents = resp["arguments"]["torrents"].sort do |a, b|
        s = (a["isFinished"]?1:0) <=> (b["isFinished"]?1:0)
        s = ((a["isStalled"] || a["eta"]<0)?1:0) <=> ((b["isStalled"] || b["eta"]<0)?1:0) if s == 0
        s = a["eta"] <=> b["eta"] if s == 0
        s
      end
      torrents.each do |torrent|
        color = "blue" if torrent["isFinished"]
        color = "gray" if torrent["isStalled"] || torrent["eta"] < 0
        color = "white" if color.to_s.empty?
        percent = torrent["percentDone"].to_f * 100
        speed = torrent["rateDownload"].to_speed
        out << "--%-50s  %2.1f%% | color=%s font=Courier " % [torrent["name"][0,50], percent, color]
        out << "--%-50s  %s | color=%s font=Courier alternate=true" % [torrent["name"][0,50], speed, color]
      end
    end
    out
  end

  private

  def call_rpc(method)
    @output[method] ||= (
      _, resp = with_cached_value("transmission_id") do
        raw_call_rpc(method)
      end
      resp
    )
  end

  def raw_call_rpc(method, id="xxx", json = true)
    header = {'x-transmission-session-id': id}
    req = Net::HTTP::Post.new(@uri.path, header)
    req.basic_auth @user, @password unless @user.empty?
    req.body = '{"method":"' + method + '","arguments":{"fields":["id","name","error","errorString","eta","isFinished","isStalled","leftUntilDone","percentDone","rateDownload", "rateUpload"]}}'
    
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.use_ssl = @uri.scheme == "https" 
    resp = http.start {|http| http.request(req) }.body
    if resp.include? "409: Conflict"
      new_id = /\<code\>X-Transmission-Session-Id\: (.*)\<\/code\>/.match(resp)[1]
      id, resp = raw_call_rpc(method, new_id, false)
    end
    return id, JSON.parse(resp) if json
    return id, resp
  end
end

def get_counter
  @counter ||= (
    c = $cache['counter'] ? $cache['counter'] : 0
    $cache['counter'] = c + 1
    c
  )
end

def with_cached_value(name)
  value = $cache[name]
  result = yield value
  new_value = Array(result)[0]
  $cache[name] = new_value
  result
end

def every(num, obj, func)
  name = func.to_s
  name = obj.name + "_" + name if obj != self
  begin
    if get_counter % num == 0 || $cache[name].nil?
      out = obj.send(func) 
      out = [] if out.nil?
      $cache[name] = out.join("\n")
    end
    puts $cache[name]
  rescue => e
    $error = true
    puts "#{name} :exclamation: | color=red"
    puts "--Error: #{e} | color=white"
    e.backtrace.each {|line| puts "--#{line} | color=white"}
  end
end

def with_captured_stdout
  original_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout.string
ensure
  $stdout = original_stdout
end

#######################################################################################
### MAIN

# Load config if it exists
if File.exist?(File.expand_path(CONFIG_FILE))
  File.open(File.expand_path(CONFIG_FILE), "r:UTF-8") do |f| 
    @config = YAML.load(f.read)
  end
end

# Load cache if it exists
if File.exist?(CACHE_FILE)
  begin
    File.open(CACHE_FILE, "r:UTF-8") do |f| 
      $cache = JSON.parse(f.read)
    end
  rescue
    $cache = Hash.new
  end
end

tautulli = TautulliPlugin.new(@config["tautulli"])
output = with_captured_stdout do
  every 1, tautulli, :server_name
  every 1, tautulli, :total_bandwidth
  every 3, tautulli, :recently_added
  every 24, tautulli, :libraries
  every 1, tautulli, :plex_sessions

  # Sonarr
  if @config["sonarr"]
    sonarr = PVRPlugin.new("sonarr", @config["sonarr"])
    puts "---"
    puts "Sonarr | image=#{SONARR_ICON} href=#{@config["sonarr"]["url"]}"
    every 12, sonarr, :calendar
    every 6, sonarr, :missing
  end

  # Radarr
  if @config["radarr"]
    radarr = PVRPlugin.new("radarr", @config["radarr"])
    puts "---"
    puts "Radarr | image=#{RADARR_ICON} href=#{@config["radarr"]["url"]}"
    every 12, radarr, :calendar
  end

  # Transmission
  if @config["transmission"]
    transmission = TransmissionPlugin.new(@config["transmission"])
    puts "---"
    puts "Transmission | image=#{TRANSMISSION_ICON} href=#{transmission.web_url}"
    every 1, transmission, :speed
    every 1, transmission, :queue
  end

  puts "---\nRefresh... | bash='#{$0}' param1=refresh terminal=false refresh=true"
end

begin
  num_sessions = tautulli.num_sessions
  num_sessions = "" if num_sessions == 0
rescue => e
  num_sessions = ":interrobang:"
end

if $error
  puts ":exclamation: | image=#{PMS_ICON} color=red"
else
  puts "#{num_sessions} | image=#{PMS_ICON}"
end
puts "---"

STDOUT.puts output

# Save cached info
File.open(CACHE_FILE, "w:UTF-8") do |f| 
  f.write $cache.to_json
end 
