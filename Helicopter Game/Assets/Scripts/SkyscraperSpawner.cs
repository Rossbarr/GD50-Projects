using System.Collections;
using UnityEngine;

public class SkyscraperSpawner : MonoBehaviour
{
    public GameObject[] prefabs;
    public static float speed = 10f;

    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(SpawnSkyscrapers());
    }

    IEnumerator SpawnSkyscrapers()
    {
        while (true) 
        {
            Instantiate(prefabs[Random.Range(0, prefabs.Length)], new Vector3(0, Random.Range(-50, -30), 30), 
                Quaternion.identity);

            yield return new WaitForSeconds(Random.Range(2, 7));
        }
    }
}
