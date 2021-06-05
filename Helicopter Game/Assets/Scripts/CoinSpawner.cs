using System.Collections;
using UnityEngine;

public class CoinSpawner : MonoBehaviour
{
    public GameObject[] prefabs;

    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(SpawnCoins());
    }

    IEnumerator SpawnCoins()
    {
        while (true)
        {
            int coinsThisRow = Random.Range(1, 4);

            for (int i = 0; i < coinsThisRow; i++)
            {
                Instantiate(prefabs[Random.Range(0, prefabs.Length)], new Vector3(0, Random.Range(-10, 10), 30), 
                    Quaternion.Euler(0, 0, 90));
            }

            yield return new WaitForSeconds(Random.Range(1, 5)); 
        }
    }
} 
